import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/editorShortcutsAndActions.dart';
import 'package:editor_app/base/helpers/inputEffectDelegator.dart';
import 'package:editor_app/base/models/EditorLiteModel.dart';
import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/base/styles/editorStyles.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:editor_app/types/CursorPos.dart';
import 'package:editor_app/types/OpResult.dart';
import 'package:editor_app/utils/wordActions.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Components
import 'package:editor_app/base/components/Line.dart';

// Models
import 'package:editor_app/base/models/Document.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

const DEFAULT_GUTTER_PADDING = 8.0;

class EditorLite extends StatefulWidget {

  final EditorLiteModel model;

  const EditorLite({ super.key, required this.model });

  @override
  State<EditorLite> createState() => _EditorLite();
}

class _EditorLite extends State<EditorLite> {
  late ShortcutsAndActionsMaps sAndAMaps;

  // Convenience local property for easier access.
  // Don't want to keep using widget.model.<propName> everytime
  late EditorLiteModel model;

  @override
  void initState() {
    super.initState();

    model = widget.model;
    sAndAMaps = getEditorShortcutsAndActions(
      onZoomIn: handleZoomIn,
      onZoomOut: handleZoomOut,
      onSave: handleSave,
      onWordEnd: handleGoToWordEnd,
      onWordStart: handleGoToWordStart,
      onLineEnd: handleLineEnd,
      onLineStart: handleLineStart
    );
  }

  @override
  void didChangeDependencies () {
    super.didChangeDependencies();
    model.lineNumberGutterWidth = getLineNumberGutterWidth();
    updateLongestLineWidth();
  }

  @override
  void didUpdateWidget(covariant EditorLite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.model != widget.model) {
      model = widget.model;
    }
  }

  void updateLongestLineWidth () {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final nLine = model.document.lineAtIndex(model.document.longestLineIndex);

    if (nLine == null) {
      return;
    }

    final lineNumberPainter = TextPainter(
      text: TextSpan(
        text: nLine.pcStr.piecedValue,style: defaultStyle.merge(getContentStyle())
      ),
      textDirection: TextDirection.ltr
    );
    double res;

    lineNumberPainter.layout();
    res = lineNumberPainter.width;
    lineNumberPainter.dispose();

    setState(() {
      model.longestLineWidth = res;
    });
  }
  bool updateCursorPosition (int updatedLine, int updatedIndex,{bool skipScroll = false}) {

    var currentLine = model.document.lineAtIndex(updatedLine);

    if (currentLine == null) {
      return false;
    }

    if (
      updatedLine < 0 || updatedLine >= model.document.getLength() ||
      updatedIndex < 0 || updatedIndex > currentLine.pcStr.piecedValue.length
    )
    {
      log('Cursor going out of bounds', name: 'updateCursorPosition');
      return false;
    }
    setState(() {
      model.cursorLine = updatedLine;
      model.cursorIndex = updatedIndex;
    });

    if (model.vLineScrollController.hasClients) {
      // Check if the current line is within the viewport
      var viewportHeight = model.vLineScrollController.position.viewportDimension;
      var offset = model.vLineScrollController.offset;
      double lineHeight = (edSettings.fontSize * edSettings.lineHeightMultiplier);
      var lineTop = lineHeight * (updatedLine);
      var lineBottom = lineHeight * (updatedLine + 1);

      if (lineTop < offset) {
        model.vLineScrollController.jumpTo(lineTop);
      }
      else if (lineBottom >= (offset + viewportHeight)) {
        model.vLineScrollController.jumpTo(lineBottom - viewportHeight);
      }
    }

    return true;
  }

  void handleInsert (String? key, KeyEvent event) {
    int updatedIndex = model.cursorIndex, updatedLine = model.cursorLine;

    if (key == null) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        model.document.insertCharacter(model.cursorLine, model.cursorIndex, '\n');
        updatedLine += 1;
        updatedIndex = 0;
      }
    }
    else {
      model.document.insertCharacter(model.cursorLine, model.cursorIndex, key);
      updatedIndex +=1;
    }

    updateCursorPosition(updatedLine, updatedIndex);
    updateLongestLineWidth();
  }

  /// A lot of this logic is a reflection of deleteFromLine in
  /// Document model. Maybe, the insert and delete functions in Document
  /// should return the updated cursor line and index post operations.

  void handleBackspacePress (KeyEvent event) {
    NotifyingLine? nLine = model.document.lineAtIndex(model.cursorLine);
    NotifyingLine? prevLine = model.document.lineAtIndex(model.cursorLine - 1);
    
    int updatedIndex = model.cursorIndex, updatedLine = model.cursorLine;

    if (nLine == null) {
      return;
    }

    model.document.deleteCharacter(model.cursorLine, model.cursorIndex - 1);

    switch (model.cursorIndex == 0) {
      case true: {
        switch (model.cursorLine == 0) {
          case true: {
            break;
          }
          case false: {
            updatedLine -= 1;

            if (prevLine == null) {
              break;
            }

            updatedIndex = prevLine.pcStr.piecedValue.length;
          }
        }

        break;
      }
      case false: {
        updatedIndex -= 1;
        break;
      }
    }

    updateCursorPosition(updatedLine, updatedIndex);
    updateLongestLineWidth();
  }

  void handleShortcutPress (KeyEvent event) {

  }

  /// This function calculates the total width the line gutter is supposed to take
  /// at different zoom levels. I tried having a constant gutter width of 64px.
  /// But the moment the content cannot fit inside this constant width (at high zoom levles), the
  /// line number texts ended up breaking. So, I have this function which scales the
  /// gutter width as well.
  double getLineNumberGutterWidth () {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final lineNumberPainter = TextPainter(
      text: TextSpan(
        text: "99999",style: defaultStyle.merge(getContentStyle())
      ),
      textDirection: TextDirection.ltr
    );
    double res;

    lineNumberPainter.layout();
    res = lineNumberPainter.width;
    lineNumberPainter.dispose();

    // Magic number 16.0 because 
    return res + 2*DEFAULT_GUTTER_PADDING;
  }

  void handleZoomIn (ZoomInIntent intent) {
    edSettings.setFontSize(edSettings.fontSize + 1);
    setState(() {
      model.lineNumberGutterWidth = getLineNumberGutterWidth();
    });
    updateLongestLineWidth();
  }
  void handleZoomOut (ZoomOutIntent intent) {
    edSettings.setFontSize(edSettings.fontSize - 1);
    setState(() {
      model.lineNumberGutterWidth = getLineNumberGutterWidth();
    });
    updateLongestLineWidth();
  }

  void handleSave (SaveIntent intent) async {
    OpResult res;
    String name = 'EditorLite~handleSave';
    if (!model.document.isAttachedToFile) {
      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: 'untitled'
      );

      if (location == null) {
        log('User has cancelled file save', name: name);
        return;
      }
      res = await model.document.create(File(location.path));
    }
    else {
      res = await model.document.save();
    }

    if (!res.success) {
      log('File could not be saved. ${res.errMsg}', name: name);
      // ToDo: Implement popup that file could not be saved.
    }
  }
  void handleDeletePress (KeyEvent event) {
    
  }

  void handleNonKeyDownEvent (KeyEvent event) {
    return;
  }

  void handleArrowKeyPress (KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp: {
        var updatedLine = model.cursorLine, updatedIndex = model.cursorIndex;

        updatedLine--;

        if (model.cursorLine == 0) {
          updatedIndex = 0;
          updatedLine++; // resetting the line value from earlier.
          // The reason I am doing it this way is because I want optimistic update of the value.
          // Most of the times, the user is not going to be on line 0.
          // Making the same check cursorLine == 0 for every case when we know the op is most probably going
          // to be on the else block seems unnecessary. So, I update first and then if user is on line 0,
          // I revert my change.
          // I might be wrong. Programs are probably very fast. But I'll retain this unless there's something
          // significantly wrong with it.
        }

        NotifyingLine? targetLine = model.document.lineAtIndex(updatedLine);
        if (targetLine!= null && updatedIndex > targetLine.pcStr.piecedValue.length) {
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowDown: {
        var updatedLine = model.cursorLine, updatedIndex = model.cursorIndex;
        NotifyingLine? currentLine = model.document.lineAtIndex(model.cursorLine);

        updatedLine++;

        if (model.cursorLine == (model.document.getLength()-1) && currentLine != null) {
          updatedLine--; // reset from above
          updatedIndex = currentLine.pcStr.piecedValue.length;
        }

        NotifyingLine? targetLine = model.document.lineAtIndex(updatedLine);
        if (targetLine!= null && updatedIndex > targetLine.pcStr.piecedValue.length) {
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowLeft: {
        var updatedLine = model.cursorLine, updatedIndex = model.cursorIndex;

        updatedIndex--;

        if (model.cursorIndex == 0) {
          updatedLine--;

          NotifyingLine? targetLine = model.document.lineAtIndex(updatedLine);

          if (targetLine == null) {
            return;
          }
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowRight: {
        var updatedLine = model.cursorLine, updatedIndex = model.cursorIndex;
        NotifyingLine? currentLine = model.document.lineAtIndex(model.cursorLine);

        updatedIndex++;

        if (currentLine != null && model.cursorIndex == currentLine.pcStr.piecedValue.length) {
          updatedLine++;
          updatedIndex = 0;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
    }
    return;
  }

  void handleTapDownEvent (int lineIndex, TapDownDetails details) {
    
    NotifyingLine nLine = model.document.lineAtIndex(lineIndex)!;
    int updatedLine = lineIndex, updatedIndex = model.cursorIndex;

    // TextPainter specific logic:
    // We are merging the default style with the text style because
    // that is what the Line component does internally.
    // Not doing this means that the TextPainter offset calculation
    // fails in cases of non-default styles. Basically, other than the
    // system default style, every other style will fail.
    final defaultStyle = DefaultTextStyle.of(context).style;
    final effectiveStyle = defaultStyle.merge(getContentStyle());
    final painter = TextPainter(
      text: TextSpan(text: nLine.pcStr.piecedValue, style: effectiveStyle),
      textDirection: TextDirection.ltr
    );
    Offset offset = Offset(details.localPosition.dx, 0);

    painter.layout();
    updatedIndex = painter.getPositionForOffset(offset).offset;

    painter.dispose();

    updateCursorPosition(updatedLine, updatedIndex);
  }

  void handleGoToWordEnd (WordEndIntent intent) {
    CursorPos newPos = getNextWordStart(originalCursorIndex: model.cursorIndex, originalLineIndex: model.cursorLine, document: model.document);
    setState(() {
      model.cursorIndex = newPos.index;
      model.cursorLine = newPos.line;
    });
  }
  void handleGoToWordStart (WordStartIntent intent) {
    CursorPos newPos = getPreviousWordStart(originalCursorIndex: model.cursorIndex, originalLineIndex: model.cursorLine, document: model.document);
    setState(() {
      model.cursorIndex = newPos.index;
      model.cursorLine = newPos.line;
    });
  }
  void handleLineEnd (LineEndIntent intent) {
    String? currentLine = model.document.lineAtIndex(model.cursorLine)?.pcStr.piecedValue;
    String name = 'EditorLite~handleLineEnd';
    String msg;

    if (currentLine == null) {
      msg = "Current line is null. This shouldn't happen";
      log(msg, name: name);
      throw('$name:$msg');
    }

    updateCursorPosition(model.cursorLine, currentLine.length);
  }
  void handleLineStart (LineStartIntent intent) {
    String? currentLine = model.document.lineAtIndex(model.cursorLine)?.pcStr.piecedValue;
    String name = 'EditorLite~handleLineStart';
    String msg;

    if (currentLine == null) {
      msg = "Current line is null. This shouldn't happen";
      log(msg, name: name);
      throw('$name:$msg');
    }

    final newPos = getFirstWordOrOtherBoundaryStart(originalCursorIndex: model.cursorIndex, originalLineIndex: model.cursorLine, document: model.document);
    setState(() {
      model.cursorIndex = newPos.index;
      model.cursorLine = newPos.line;
    });
  }

  KeyEventResult handleKeyEventV2 (int lineIndex, FocusNode node, KeyEvent event) {
    return inputEffectDelegator(
      event: event,
      onShortcut: handleShortcutPress,
      onDelete: handleDeletePress,
      onBackspace: handleBackspacePress,
      onInsert: handleInsert,
      onNonKeyDownEvent: handleNonKeyDownEvent,
      onArrowKey: handleArrowKeyPress
    );
  }

  @override
  Widget build(BuildContext context) {
    double lineHeight = edSettings.lineHeightMultiplier * edSettings.fontSize;
    final gutter = ListView.builder(
      controller: model.vGutterScrollController,
      itemCount: model.document.getLength(),
      itemBuilder: (context, i) {
      var cPos = model.cursorLine == i ? model.cursorIndex : null;
      return Container(
        height: lineHeight,
        color: cPos == null ? null : ACTIVE_LINE_BACKGROUND,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: DEFAULT_GUTTER_PADDING),
        child: Text(
          (i+1).toString(),
          style: TextStyle(
            color: cPos == null ? LINE_NUMBER_TEXT_COLOR : ACTIVE_LINE_NUMBER_TEXT_COLOR,
            fontSize: edSettings.fontSize
          ),
        )
      );
    });
    final linesList = RawScrollbar(
      controller: model.hScrollController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: model.hScrollController,
            child: RawScrollbar(
              controller: model.vLineScrollController,
              child: Row(children: [
                SizedBox(
                  width: math.max(model.longestLineWidth, constraints.maxWidth),
                  child: ListView.builder(
                    controller: model.vLineScrollController,
                    itemCount: model.document.getLength(),
                    itemBuilder: (context, i) {
                    var cPos = model.cursorLine == i ? model.cursorIndex : null;
                    NotifyingLine? currentLine = model.document.lineAtIndex(i);

                    if (currentLine == null) {
                      return null;
                    }

                    return Container(
                      height: lineHeight,
                      width: model.lineNumberGutterWidth,
                      child: GestureDetector(
                        onTapDown: (TapDownDetails details) { handleTapDownEvent(i, details); },
                        child: Line(
                          text: currentLine.pcStr.piecedValue,
                          onKeyEvent: (FocusNode node, KeyEvent event) => handleKeyEventV2(i, node, event),
                          nLine: currentLine,
                          cursorIndex: cPos,
                          contentStyle: getContentStyle(),
                        )
                      )
                    );
                  })
                  )
              ],)
            )
          );
        },
      )
    );
    final viewWidget = Container(
      width: double.infinity,
      height: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: model.lineNumberGutterWidth,
            child: gutter
          ),
          Expanded(
            child: linesList
          )
        ]
      ),
    );
    final wrappedWidget = Shortcuts(
      shortcuts: sAndAMaps.shortcuts,
      child: Actions(
        actions: sAndAMaps.actions,
        child: viewWidget
      )
    );

    return wrappedWidget;
  }
}
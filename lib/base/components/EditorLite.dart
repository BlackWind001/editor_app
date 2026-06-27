import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'package:editor_app/base/helpers/ShortcutsAndActionMaps.dart';
import 'package:editor_app/base/helpers/editorShortcutsAndActions.dart';
import 'package:editor_app/base/helpers/inputEffectDelegator.dart';
import 'package:editor_app/base/models/EditorSettings.dart';
import 'package:editor_app/base/styles/editorStyles.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:editor_app/types/OpResult.dart';
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

  const EditorLite({ super.key, required this.document });

  final Document document;

  @override
  State<EditorLite> createState() => _EditorLite();
}

class _EditorLite extends State<EditorLite> {
  String valueOnDisk = '';
  int cursorLine = 0;
  int cursorIndex = 0;
  late ScrollController _vLineScrollController = ScrollController();
  late ScrollController _vGutterScrollController = ScrollController();
  final LinkedScrollControllerGroup scrollControllerGroup = LinkedScrollControllerGroup();
  final ScrollController _hScrollController = ScrollController();
  late Document document;
  late ShortcutsAndActionsMaps sAndAMaps;
  double lineNumberGutterWidth = GUTTER_WIDTH;
  double longestLineWidth = 0.0;

  @override
  void initState() {
    super.initState();

    document = widget.document;
    sAndAMaps = getEditorShortcutsAndActions(onZoomIn: handleZoomIn, onZoomOut: handleZoomOut, onSave: handleSave);
    _vLineScrollController = scrollControllerGroup.addAndGet();
    _vGutterScrollController = scrollControllerGroup.addAndGet();
  }

  @override
  void didChangeDependencies () {
    super.didChangeDependencies();
    lineNumberGutterWidth = getLineNumberGutterWidth();
    updateLongestLineWidth();
  }

  @override
  void didUpdateWidget(covariant EditorLite oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.document != document) {
      print('didUpdateWidget: NOT IMPLEMENTED');
    }
  }

  @override
  void dispose () {
    _vLineScrollController.dispose();
    _vGutterScrollController.dispose();
    _hScrollController.dispose();
    super.dispose();
  }

  void updateLongestLineWidth () {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final nLine = document.lineAtIndex(document.longestLineIndex);

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
      longestLineWidth = res;
    });
  }
  bool updateCursorPosition (int updatedLine, int updatedIndex,{bool skipScroll = false}) {

    var currentLine = document.lineAtIndex(updatedLine);

    if (currentLine == null) {
      return false;
    }

    if (
      updatedLine < 0 || updatedLine >= document.getLength() ||
      updatedIndex < 0 || updatedIndex > currentLine.pcStr.piecedValue.length
    )
    {
      log('Cursor going out of bounds', name: 'updateCursorPosition');
      return false;
    }
    setState(() {
      cursorLine = updatedLine;
      cursorIndex = updatedIndex;
    });

    if (_vLineScrollController.hasClients) {
      // Check if the current line is within the viewport
      var viewportHeight = _vLineScrollController.position.viewportDimension;
      var offset = _vLineScrollController.offset;
      double lineHeight = (edSettings.fontSize * edSettings.lineHeightMultiplier);
      var lineTop = lineHeight * (updatedLine);
      var lineBottom = lineHeight * (updatedLine + 1);

      if (lineTop < offset) {
        _vLineScrollController.jumpTo(lineTop);
      }
      else if (lineBottom >= (offset + viewportHeight)) {
        _vLineScrollController.jumpTo(lineBottom - viewportHeight);
      }
    }

    return true;
  }

  void handleInsert (String? key, KeyEvent event) {
    int updatedIndex = cursorIndex, updatedLine = cursorLine;

    if (key == null) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        document.insertNewLine(cursorLine, cursorIndex);
        updatedLine += 1;
        updatedIndex = 0;
      }
    }
    else {
      document.insertInLine(cursorLine, cursorIndex, key);
      updatedIndex +=1;
    }

    updateCursorPosition(updatedLine, updatedIndex);
    updateLongestLineWidth();
  }

  void handleBackspacePress (KeyEvent event) {
    NotifyingLine? nLine = document.lineAtIndex(cursorLine);
    int updatedIndex = cursorIndex, updatedLine = cursorLine;

    if (nLine == null) {
      return;
    }

    if (cursorIndex == 0) {
      if (cursorLine != 0) {
        NotifyingLine? prevLine = document.lineAtIndex(cursorLine - 1);

        if (prevLine == null) {
          return;
        }

        document.mergeLines(cursorLine - 1, cursorLine + 1);
        updatedLine -= 1;
        updatedIndex = prevLine.pcStr.piecedValue.length;
      }
      else {
        return;
      }
    }
    else {
      nLine.delete(cursorIndex - 1, 1);
      updatedIndex -= 1;
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
      lineNumberGutterWidth = getLineNumberGutterWidth();
    });
    updateLongestLineWidth();
  }
  void handleZoomOut (ZoomOutIntent intent) {
    edSettings.setFontSize(edSettings.fontSize - 1);
    setState(() {
      lineNumberGutterWidth = getLineNumberGutterWidth();
    });
    updateLongestLineWidth();
  }

  void handleSave (SaveIntent intent) async {
    OpResult res;
    String name = 'EditorLite~handleSave';
    if (!document.isAttachedToFile) {
      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: 'untitled'
      );

      if (location == null) {
        log('User has cancelled file save', name: name);
        return;
      }
      res = await document.create(File(location.path));
    }
    else {
      res = await document.save();
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
        var updatedLine = cursorLine, updatedIndex = cursorIndex;

        updatedLine--;

        if (cursorLine == 0) {
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

        NotifyingLine? targetLine = document.lineAtIndex(updatedLine);
        if (targetLine!= null && updatedIndex > targetLine.pcStr.piecedValue.length) {
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowDown: {
        var updatedLine = cursorLine, updatedIndex = cursorIndex;
        NotifyingLine? currentLine = document.lineAtIndex(cursorLine);

        updatedLine++;

        if (cursorLine == (document.getLength()-1) && currentLine != null) {
          updatedLine--; // reset from above
          updatedIndex = currentLine.pcStr.piecedValue.length;
        }

        NotifyingLine? targetLine = document.lineAtIndex(updatedLine);
        if (targetLine!= null && updatedIndex > targetLine.pcStr.piecedValue.length) {
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowLeft: {
        var updatedLine = cursorLine, updatedIndex = cursorIndex;

        updatedIndex--;

        if (cursorIndex == 0) {
          updatedLine--;

          NotifyingLine? targetLine = document.lineAtIndex(updatedLine);

          if (targetLine == null) {
            return;
          }
          updatedIndex = targetLine.pcStr.piecedValue.length;
        }

        updateCursorPosition(updatedLine, updatedIndex);
        break;
      }
      case LogicalKeyboardKey.arrowRight: {
        var updatedLine = cursorLine, updatedIndex = cursorIndex;
        NotifyingLine? currentLine = document.lineAtIndex(cursorLine);

        updatedIndex++;

        if (currentLine != null && cursorIndex == currentLine.pcStr.piecedValue.length) {
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
    
    NotifyingLine nLine = document.lineAtIndex(lineIndex)!;
    int updatedLine = lineIndex, updatedIndex = cursorIndex;

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
      controller: _vGutterScrollController,
      itemCount: document.getLength(),
      itemBuilder: (context, i) {
      var cPos = cursorLine == i ? cursorIndex : null;
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
      controller: _hScrollController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _hScrollController,
            child: RawScrollbar(
              controller: _vLineScrollController,
              child: Row(children: [
                SizedBox(
                  width: math.max(longestLineWidth, constraints.maxWidth),
                  child: ListView.builder(
                    controller: _vLineScrollController,
                    itemCount: document.getLength(),
                    itemBuilder: (context, i) {
                    var cPos = cursorLine == i ? cursorIndex : null;
                    NotifyingLine? currentLine = document.lineAtIndex(i);

                    if (currentLine == null) {
                      return null;
                    }

                    return Container(
                      height: lineHeight,
                      width: lineNumberGutterWidth,
                      color: EDITOR_BACKGROUND,
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
      color: EDITOR_BACKGROUND,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: lineNumberGutterWidth,
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
import 'dart:developer';
import 'dart:io';
import 'package:editor_app/base/helpers/FileLoader.dart';
import 'package:editor_app/base/helpers/inputEffectDelegator.dart';
import 'package:editor_app/constants/editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Components
import 'package:editor_app/base/components/Line.dart';
import 'package:editor_app/base/components/KeypressWidget.dart';

// Models
import 'package:editor_app/base/models/Document.dart';

// Utils
import 'package:editor_app/utils/isShortcut.dart';

class EditorLite extends StatefulWidget {

  const EditorLite({ super.key, this.filePath });

  final String? filePath;

  @override
  State<EditorLite> createState() => _EditorLite();
}

class _EditorLite extends State<EditorLite> {
  String valueOnDisk = '';
  int cursorLine = 0;
  int cursorIndex = 0;
  final ScrollController _scrollController = ScrollController();
  late Document document;


  void handleInitialFileLoadAndRead (String filePath) {
    const errorName = 'EditorLite~handleInitialFileLoadAndRead';
    List<String> lines = [];
    try {
      var contents = Fileloader.getFileContentsSync(filePath);

      lines = contents;
      valueOnDisk = contents.join('\n');
    } on FileSystemException catch (fileSysException, trace) {
      log(
        'Error occurred while loading file: $filePath.',
        name: errorName,
        error: fileSysException,
        stackTrace: trace
      );
    } catch (e, trace) {
      log(
        'Encountered error',
        name: errorName,
        error: e,
        stackTrace: trace
      );
    } finally {
      document = Document.fromLines(lines);
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.filePath == null) {
      valueOnDisk = 'Hey there.\nWhatcha doing?';
      document = Document(valueOnDisk);
    }
    else {
      handleInitialFileLoadAndRead(widget.filePath!);
    }
  }

  @override
  void dispose () {
    _scrollController.dispose();
    super.dispose();
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

    if (_scrollController.hasClients) {
      // Check if the current line is within the viewport
      var viewportHeight = _scrollController.position.viewportDimension;
      var offset = _scrollController.offset;
      var lineTop = EDITOR_LINE_HEIGHT * (updatedLine);
      var lineBottom = EDITOR_LINE_HEIGHT * (updatedLine + 1);

      if (lineTop < offset) {
        _scrollController.jumpTo(lineTop);
      }
      else if (lineBottom >= (offset + viewportHeight)) {
        _scrollController.jumpTo(lineBottom - viewportHeight);
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
  }

  void handleBackspacePress (KeyEvent event) {
    NotifyingLine? nLine = document.lineAtIndex(cursorLine);
    int updatedIndex = cursorIndex, updatedLine = cursorLine;

    if (nLine == null) {
      return;
    }

    nLine.delete(cursorIndex - 1, 1);
    if (cursorIndex == 0) {
      if (cursorLine != 0) {
        updatedLine -= 1;
      }
    }
    else {
      updatedIndex -= 1;
    }

    updateCursorPosition(updatedLine, updatedIndex);
  }

  void handleShortcutPress (KeyEvent event) {

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
    final effectiveStyle = defaultStyle.merge(contentStyle);
    final painter = TextPainter(
      text: TextSpan(text: nLine.pcStr.piecedValue, style: effectiveStyle),
      textDirection: TextDirection.ltr
    );
    Offset offset = Offset(details.localPosition.dx, 0);

    painter.layout();
    updatedIndex = painter.getPositionForOffset(offset).offset;

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
    final widget = KeypressWidget(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.inversePrimary,
          child: ListView.builder(
              controller: _scrollController,
              itemCount: document.getLength(),
              itemBuilder: (context, i) {
                var cPos = cursorLine == i ? cursorIndex : null;
                NotifyingLine? currentLine = document.lineAtIndex(i);

                if (currentLine == null) {
                  return null;
                }

                return Row(children: [
                  Container(
                    width: GUTTER_WIDTH,
                    height: EDITOR_LINE_HEIGHT,
                    color: cPos == null ? LINE_BACKGROUND : ACTIVE_LINE_BACKGROUND,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      (i+1).toString().padLeft(5),
                      style: TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                        color: cPos == null ? LINE_NUMBER_TEXT_COLOR : ACTIVE_LINE_NUMBER_TEXT_COLOR,
                        fontSize: FONT_SIZE
                      ),
                    )
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTapDown: (TapDownDetails details) { handleTapDownEvent(i, details); },
                      child: Line(
                        text: currentLine.pcStr.piecedValue,
                        onKeyEvent: (FocusNode node, KeyEvent event) => handleKeyEventV2(i, node, event),
                        nLine: currentLine,
                        cursorIndex: cPos
                      )
                    )
                  )
                ]);
              }
          )
      ),
    );

    // ToDo: Move the following lines to a separate registerShortcuts function
    // along with other app wide shortcut registrations.
    // Also, only register the necessary platform's shortcuts.
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.keyQ, meta: true),
      () => exit(0),
    );
    widget.register(
      const KeyPress(key: LogicalKeyboardKey.f4, alt: true),
      () => exit(0),
    );

    return widget;
  }
}
import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/data-structures/PiecableString.dart';
import 'package:editor_app/base/helpers/FileActions.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/types/OpResult.dart';
import 'package:flutter/widgets.dart';

class NotifyingLine with ChangeNotifier {
  String initial = '';
  late PiecableString pcStr;

  NotifyingLine(this.initial) {
    pcStr = PiecableString(originalString: initial);
  }

  void insert(int position, Piece toInsert) {
    pcStr.insert(position, toInsert);
    notifyListeners();
  }

  void delete(int position, int len) {
    pcStr.delete(position, len);
    notifyListeners();
  }
}

class Document {
  File? _file;
  DateTime? _lastWrittenTimestamp;
  List<NotifyingLine> _lines = [];
  int _longestLineIndex = 0;
  bool hasFileBeenModifiedExternally = false;
  bool hasUnsavedChanges = false;

  Document(String initial) {
    if (initial.isEmpty) {
      _lines = [];
      return;
    }

    _load(initial.split('\n'));
  }

  Document._ ();

  Document.fromLines(List<String> initialLines) {
    if (initialLines.isEmpty) {
      _lines = [];
      return;
    }

    _load(initialLines);
  }

  /// Factory method since we need to perform asynchronous operation
  static Future<Document> createFromPath(String path) async {
    Document instance = Document._();

    await instance._intializeFromPath(path);

    return instance;
  }

  Future<void> _intializeFromPath (String path) async {
    File? f = await FileActions.getFileIfExists(path);
    String name = 'Document.initializeFromPath';

    if (f == null) {
      log('Unable to _load file path $path', name: name);
      throw('Unable to _load file path $path');
    }

    List<String> contents = await f.readAsLines();
    _load(contents);

    _file = f;
    await DirectoryWatchers.registerListenerForFile(path, handleDirectoryEvents);
  }

  void handleDirectoryEvents (FileSystemEvent event) async {
    File? f = _file;
    String name = 'Document~handleDirectoryEvents';
    if (f == null) {
      log('File is null but the directory events are firing.', name: name);
      return;
    }
    if (event.path != f.path) {
      return;
    }

    switch (event) {
      case FileSystemDeleteEvent(): {
        log('Delete event fired for ${f.path}', name: name);
        hasFileBeenModifiedExternally = true;
        return;
      }
      case FileSystemModifyEvent(): {
        final lastModifiedTimestamp = await f.lastModified();
        if (lastModifiedTimestamp == _lastWrittenTimestamp) {
          // The change was by us so the file has not been externally modified.
          return;
        }
        log('File has been modified ${f.path}', name: name);
        hasFileBeenModifiedExternally = true;
        return;
      }
      default: {}
    }
  }

  void _load(List<String> initial) {
    int index = 0;
    int initialLongestLineLength = 0;
    _lines = initial
      .map((el) {
        if (el.length > initialLongestLineLength) {
          _longestLineIndex = index;
          initialLongestLineLength = el.length;
        }

        index++;
        return NotifyingLine(el);
      }).toList();
  }

  Future<OpResult> save () async {
    OpResult res = OpResult(success: true);
    if (_file == null) {
      return OpResult(
        success: false,
      errMsg: 'Document._file is null'
      );
    }

    if (hasFileBeenModifiedExternally) {
      return OpResult(success: false, errMsg: 'File has been modified externally');
    }

    res = await FileActions.saveFile(_file!, _linesAsString);

    if (res.success) {
      hasUnsavedChanges = false;
      _lastWrittenTimestamp = await _file!.lastModified();
    }
    else {
      hasUnsavedChanges = true;
    }

    return res;
  }

  int get longestLineIndex {
    return _longestLineIndex;
  }

  NotifyingLine? lineAtIndex (int lineIndex) {
    if (lineIndex < 0 || lineIndex >= _lines.length) {
      return null;
    }
    return _lines[lineIndex];
  }

  int getLength () {
    return _lines.length;
  }

  int _calculateLongestLineIndex () {
    int currentLongestLineLength = 0;
    int result = 0;
    for(int i = 0; i < _lines.length; i++) {
      if (_lines[i].pcStr.piecedValue.length > currentLongestLineLength) {
        result = i;
      }
    }

    return result;
  }

  String get _linesAsString {
    return _lines.map((el) { return el.pcStr.piecedValue; }).join('\n');
  }

  void insertNewLine (int lineIndex, int position) {
    NotifyingLine? nLine = lineAtIndex(lineIndex);

    if (nLine == null) {
      return;
    }

    String line = nLine.pcStr.piecedValue;
    List<String> newlyAddedLines = [];

    newlyAddedLines.add(line.substring(0, position));
    newlyAddedLines.add(line.substring(position));
    
    _lines.replaceRange(lineIndex, lineIndex + 1, newlyAddedLines.map((el) => NotifyingLine(el)));

    if (lineIndex == _longestLineIndex) {
      _longestLineIndex = _calculateLongestLineIndex();
    }
    else if (lineIndex < _longestLineIndex) {
      _longestLineIndex++;
    }

    hasUnsavedChanges = true;
  }

  void insertInLine(int lineIndex, int position, Piece toInsert) {

    NotifyingLine? nLine = lineAtIndex(lineIndex);
    NotifyingLine? longestLine = _lines[longestLineIndex];
    int newLength;

    if (nLine == null) {
      return;
    }
    nLine.insert(position, toInsert);

    newLength = nLine.pcStr.piecedValue.length;
  
    if (newLength > longestLine.pcStr.piecedValue.length) {
      _longestLineIndex = lineIndex;
    }
    hasUnsavedChanges = true;
  }

  void deleteFromLine(int lineIndex, int position, int len) {
    NotifyingLine? nLine = lineAtIndex(lineIndex);

    if (nLine == null) {
      return;
    }
    nLine.delete(position, len);

    if (lineIndex == _longestLineIndex) {
      // Recompute longest line length.
      _longestLineIndex = _calculateLongestLineIndex();
    }
    hasUnsavedChanges = true;
  }

  void mergeLines (int startLineIndex, int endLineIndex) {
    String mergedLine = _lines.sublist(startLineIndex, endLineIndex).map((l) => l.pcStr.piecedValue).join('');
    NotifyingLine? longestLine = _lines[longestLineIndex];

    _lines.replaceRange(startLineIndex, endLineIndex, [NotifyingLine(mergedLine)]);

    if (mergedLine.length > longestLine.pcStr.piecedValue.length) {
      _longestLineIndex = startLineIndex;
    }
    hasUnsavedChanges = true;
  }

  void cleanup () {
    File? f = _file;

    if (f == null) {
      return;
    }

    DirectoryWatchers.unregisterListenerForFile(f.path);
  }

}
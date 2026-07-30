import 'dart:developer';
import 'dart:io';

import 'package:editor_app/base/data-structures/PiecableString.dart';
import 'package:editor_app/base/helpers/FileActions.dart';
import 'package:editor_app/base/models/DirectoryWatchers.dart';
import 'package:editor_app/types/OpResult.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

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
  late String id;
  File? _file;
  DateTime? _lastWrittenTimestamp;
  List<NotifyingLine> _lines = [];
  int _longestLineIndex = 0;
  bool hasFileBeenModifiedExternally = false;
  bool hasUnsavedChanges = false;

  Document(String initial) {
    id = uuid.v4();
    if (initial.isEmpty) {
      _lines = [];
      return;
    }

    _load(initial.split('\n'));
  }

  Document._ () {
    id = uuid.v4();
  }

  Document.fromLines(List<String> initialLines) {
    id = uuid.v4();
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

  Future<OpResult> create (File f) async {
    OpResult res = await FileActions.createFile(f, _linesAsString);

    if (res.success) {

      // This currently sort of restarts the instance's file details.
      // _initializeFromPath internally calls _load which current does NOT
      // reset all values. So, this might become a source of bugs later on.
      _intializeFromPath(f.path);
    }

    return res;
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

  bool get isAttachedToFile {
    return _file != null;
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
        currentLongestLineLength = _lines[i].pcStr.piecedValue.length;
      }
    }

    return result;
  }

  String get _linesAsString {
    return _lines.map((el) { return el.pcStr.piecedValue; }).join('\n');
  }

  void insertCharacter (int lineIndex, int position, Piece toInsert) {
    NotifyingLine? nLine = lineAtIndex(lineIndex);
    NotifyingLine? longestLine = _lines[longestLineIndex];
    int newLength;

    if (nLine == null || position < 0 || position > nLine.pcStr.piecedValue.length || toInsert.length != 1) {
      throw '''Document~insertCharacter: Sanity check failed while inserting character:
      nLine == null: ${nLine == null}
      position < -1: ${position < -1}
      position >= nLine.pcStr.piecedValue.length: ${position >= (nLine?.pcStr.piecedValue.length ?? 0)}
      toInsert.length != 1: ${toInsert.length != 1}
      ''';
    }

    // I kinda hate that I am using a switch statement instead of if-else but I also weirdly love it.
    // This is cursed code that I shall protect.
    switch (toInsert == '\n') {
      case true: {
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
        break;
      }
      case false: {
        nLine.insert(position, toInsert);
        newLength = nLine.pcStr.piecedValue.length;

        if (newLength > longestLine.pcStr.piecedValue.length) {
          _longestLineIndex = lineIndex;
        }
        break;
      }
    }

    hasUnsavedChanges = true;
  }

  /// Deletes a character at position.
  /// deleteCharacter(2, 0) - deletes the 0th index character on line 2
  /// deleteCharacter(2, -1) - merges the current line 2 with line 1.
  void deleteCharacter (int lineIndex, int position) {
    int lengthToDelete = 1;
    NotifyingLine? nLine = lineAtIndex(lineIndex);
    NotifyingLine? longestLine = _lines[longestLineIndex];

    if (nLine == null || position < -1 || position >= nLine.pcStr.piecedValue.length) {
      throw '''Document~deleteCharacter: Sanity check failed while deleting character:
      nLine == null: ${nLine == null}
      position < -1: ${position < -1}
      position >= nLine.pcStr.piecedValue.length: ${position >= (nLine?.pcStr.piecedValue.length ?? 0)}
      ''';
    }

    /// Switch case to decide if the current and previous lines should be merged.
    /// Or if the deletion is supposed to happen in the current line
    switch (position == -1) {
      case true: {

        /// Switch case for what to do if the current line is the 0th line
        /// or if it is >0
        switch (lineIndex == 0) {
          case true: {
            break;
          }
          case false: {
            NotifyingLine? prevLine = lineAtIndex(lineIndex - 1);
            int newLineIndex = lineIndex - 1;

            if (prevLine == null) {
              throw '''Document~deleteCharacter: Sanity check failed while merging lines:
              prevLine == null: true
              ''';
            }

            mergeLines(lineIndex - 1, lineIndex + 1);

            if (prevLine.pcStr.piecedValue.length >= longestLine.pcStr.piecedValue.length) {
              _longestLineIndex = newLineIndex;
            }
            else {
              if (newLineIndex < _longestLineIndex) {
                _longestLineIndex--;
              }

              /// Why only the if block newLineIndex < _longestLineIndex?
              /// Case newLineIndex > _longestLineIndex does not need to be handled.
              /// _longestLine is not affected by any modifications to a line below it.
              /// Case newLineIndex == _longestLineIndex is already handled in the super if block
              /// above where we check if the new line's length greater or EQUAL to the longest line length.
            }
            break;
          }
        }
        break;
      }
      /// Technically the following else case would also match position < -1
      /// But there is a check for this already at the top. However, I'm still not a fan of
      /// this approach. Maybe I should move away from the switch case here.
      case false: {
        nLine.delete(position, lengthToDelete);

        if (lineIndex == _longestLineIndex) {
           _longestLineIndex = _calculateLongestLineIndex();
        }
        break;
      }
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

    // IMMEDIATE: What if the merged line was above the previous longest line
    // Shouldn't the longest line index be updated?
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

class DocumentsStore {
  final Map<String, Document> _map = {};

  DocumentsStore();

  void _addEntry(String key, Document d) {
    _map[key] = d;
  }

  void _removeEntry (String key) {
    _map.remove(key);
  }

  Document createEmptyDocument () {
    Document d = Document('\n');

    _addEntry(d.id, d);

    return d;
  }

  Future<Document?> createNewDocument (String filePath) async {
    Document d;
    const errorName = 'DocumentStore~createNewDocument';

    try {
      d = await Document.createFromPath(filePath);

      _addEntry(d.id, d);
      return d;
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
    }
    return null;
  }

  bool removeDocument (String key) {
    const errorName = 'DocumentStore~removeDocument';
    Document? d = _map[key];
    if (d == null) {
      log(
        'Error occurred while removing document: $key',
        name: errorName,
      );
      return false;
    }

    d.cleanup();
    _removeEntry(key);

    return true;
  }

  Document? getDocument(String key) {
    return _map[key];
  }
}

DocumentsStore documentStore = DocumentsStore();
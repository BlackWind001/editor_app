import 'package:editor_app/base/data-structures/PiecableString.dart';
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
  List<NotifyingLine> _lines = [];
  int _longestLineIndex = 0;

  Document(String initial) {
    if (initial.isEmpty) {
      _lines = [];
      return;
    }

    load(initial.split('\n'));
  }

  Document.fromLines(List<String> initialLines) {
    if (initialLines.isEmpty) {
      _lines = [];
      return;
    }

    load(initialLines);
  }

  void load(List<String> initial) {
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
  }

  void mergeLines (int startLineIndex, int endLineIndex) {
    String mergedLine = _lines.sublist(startLineIndex, endLineIndex).map((l) => l.pcStr.piecedValue).join('');
    NotifyingLine? longestLine = _lines[longestLineIndex];

    _lines.replaceRange(startLineIndex, endLineIndex, [NotifyingLine(mergedLine)]);

    if (mergedLine.length > longestLine.pcStr.piecedValue.length) {
      _longestLineIndex = startLineIndex;
    }
  }

}
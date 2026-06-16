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

  Document(String initial) {
    if (initial.isEmpty) {
      _lines = [];
      return;
    }

    _lines = initial
      .split('\n')
      .map(
        (el) => 
          NotifyingLine(el)
        ).toList();
  }

  Document.fromLines(List<String> initialLines) {
    if (initialLines.isEmpty) {
      _lines = [];
      return;
    }

    _lines = initialLines.map(
      (el) => NotifyingLine(el)
    ).toList();
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
  }

  void insertInLine(int lineIndex, int position, Piece toInsert) {

    NotifyingLine? nLine = lineAtIndex(lineIndex);

    if (nLine == null) {
      return;
    }
    nLine.insert(position, toInsert);
  }

  void deleteFromLine(int lineIndex, int position, int len) {
    NotifyingLine? nLine = lineAtIndex(lineIndex);

    if (nLine == null) {
      return;
    }
    nLine.delete(position, len);
  }

  void mergeLines (int startLineIndex, int endLineIndex) {
    String mergedLine = _lines.sublist(startLineIndex, endLineIndex).map((l) => l.pcStr.piecedValue).join('');

    _lines.replaceRange(startLineIndex, endLineIndex, [NotifyingLine(mergedLine)]);
  }

}
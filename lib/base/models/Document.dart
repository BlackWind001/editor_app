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

  void insertInLine(int lineIndex, int position, Piece toInsert) {
    _lines[lineIndex].insert(position, toInsert);
  }

  void deleteFromLine(int lineIndex, int position, int len) {
    _lines[lineIndex].delete(position, len);
  }

}
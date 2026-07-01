import 'dart:math';

import 'package:editor_app/base/models/Document.dart';
import 'package:editor_app/types/CursorPos.dart';
import 'package:editor_app/utils/WordActionUtility.dart';


CursorPos getNextWordStart (
  {
    required int originalCursorIndex,
    required int originalLineIndex,
    required Document document
  }
) {
  int currentCursorIndex = originalCursorIndex;
  int currentLineIndex = originalLineIndex;
  String? line = document.lineAtIndex(currentLineIndex)?.pcStr.piecedValue;
  String name = 'getNextWordStart';
  String concatenatedLine;

  if (line == null) {
    throw('$name: Non existent line referred');
  }

  void incrementLine () {
    currentLineIndex += 1;
    currentCursorIndex = 0;

    line = document.lineAtIndex(currentLineIndex)?.pcStr.piecedValue;

    if (line == null) {
      throw('$name: Non existent line referred');
    }
  }

  // Adding a new line character at the end so that the cursor can be updated
  // to the next line if conditions are right (aka cursor after last char)
  concatenatedLine = '$line\n';
  final nextWordIndex = 
    defaultWordCharsWordActionUtility.
    getNextWordOrPunctuationBoundaryEnd(concatenatedLine.substring(currentCursorIndex));
  
  if ((currentCursorIndex + nextWordIndex) == concatenatedLine.length) {
    try {
      incrementLine();
    }
    catch(e) {
      currentLineIndex = originalLineIndex;
      currentCursorIndex = originalCursorIndex;
    }
  }
  else {
    currentCursorIndex = min(line!.length, currentCursorIndex + nextWordIndex);
  }


  return CursorPos(line: currentLineIndex, index: currentCursorIndex);
}

CursorPos getPreviousWordStart ({
    required int originalCursorIndex,
    required int originalLineIndex,
    required Document document
  }) {
  int currentCursorIndex = originalCursorIndex;
  int currentLineIndex = originalLineIndex;
  String? line = document.lineAtIndex(currentLineIndex)?.pcStr.piecedValue;
  String name = 'getPreviousWordStart';

  if (line == null) {
    throw('$name: Non existent line referred');
  }

  void decrementLine () {
    currentLineIndex -= 1;

    line = document.lineAtIndex(currentLineIndex)?.pcStr.piecedValue;

    if (line == null) {
      throw('$name: Non existent line referred');
    }

    currentCursorIndex = line!.length;
  }

  line = '\n$line';

  final prevWordIndex =
    defaultWordCharsWordActionUtility.
    getPrevWordOrPunctuationBoundaryStart(line!.substring(0, currentCursorIndex));

  if (prevWordIndex == 0) {
    try { decrementLine(); }
    catch (e) { currentCursorIndex = originalCursorIndex; currentLineIndex = originalLineIndex; }
  }
  else {
    currentCursorIndex = prevWordIndex - 1;
  }

  return CursorPos(line: currentLineIndex, index: currentCursorIndex);
}

CursorPos getFirstWordOrOtherBoundaryStart ({
   required int originalCursorIndex,
    required int originalLineIndex,
    required Document document
}) {
  int currentCursorIndex = originalCursorIndex;
  int currentLineIndex = originalLineIndex;
  String? line = document.lineAtIndex(currentLineIndex)?.pcStr.piecedValue;
  String name = 'getFirstWordOrOtherBoundaryStart';

  if (line == null) {
    throw('$name: Non existent line referred');
  }

  final firstBoundaryIndex =  defaultWordCharsWordActionUtility.
    getFirstWordOrPunctuationBoundaryStart(line.substring(0, currentCursorIndex));


  return CursorPos(line: currentLineIndex, index: firstBoundaryIndex);

}
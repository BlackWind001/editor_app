
/**
 * What do I need?
 * 1. An array for the pieces. This array will hold all the strings and the indices - we will call each of them a Piece
 * 2. A definition of the Piece object itself.
 * 3. Use this in the insert function.
 * 4. A way to get the concatenated string
 * 5. Use this in the delete function
 */


/**
 * ToDo:
 * 1. During fragmentation, there can be pieces with empty strings. All of them need to be removed.
 * 2. Merging of pieces should be implemented and tested.
 * 3. piecableString needs to be implemented.
 */

typedef Piece = String;
typedef PieceDetails = Map<String, int>;
typedef FragmentedPieces = List<Piece>;

class PieceRangeDetails {
  int startPieceIndex = -1;
  int endPieceIndex = -1;
  int strStartIndex = -1;
  int strEndIndex = -1;

  PieceRangeDetails({
    required int startPieceIndex,
    required int endPieceIndex,
    required int strStartIndex,
    required int strEndIndex
  });

  @override
  String toString() {
    return
      '\nPieceRangeDetails' '\n'
      '\tstartPieceIndex: $startPieceIndex' '\n'
      '\tendPieceIndex: $endPieceIndex' '\n'
      '\tstrStartIndex: $strStartIndex' '\n'
      '\tstrEndIndex: $strEndIndex';
  }
}

// Note: This DS is not an exact piece table.
// The original string is not maintained immutably.
// And we don't record indices either.
// It is Piece Table-ish
class PiecableString {
  List<Piece> pieces = [];

  PiecableString ({String originalString = ''}) {
    pieces.add(originalString);
  }

  PieceDetails _getPieceDetailsForPosition (int position) {
    int count = 0;
    PieceDetails result = { 'pieceIndex': -1, 'strStartIndex': -1 };
    
    for (var (index, str) in pieces.indexed) {
      count += str.length;

      if (count >= position) {
        result['pieceIndex'] = index;
        result['strStartIndex'] = count - str.length;
        return result;
      }
    }

    return result;
  }

  PieceRangeDetails _getPiecesDetailsForRange (int position, int len) {
    int count = 0;
    PieceRangeDetails result = PieceRangeDetails(startPieceIndex: -1, endPieceIndex: -1, strEndIndex: -1, strStartIndex: -1);

    for (var (index, str) in pieces.indexed) {
      count += str.length;

      if (count >= position) {
        result.startPieceIndex = index;
        result.strStartIndex = position - (count - str.length);
        break;
      }
    }

    if (result.startPieceIndex <= -1 || result.strStartIndex <= -1) {
      return result;
    }

    for (var (baseIndex, str) in pieces.skip(result.startPieceIndex).indexed) {
      int index = baseIndex + result.startPieceIndex; // baseIndex + offset

      if(index != result.startPieceIndex) {
        count += str.length;
      }

      if (count >= position+len) {
        result.endPieceIndex = index;
        result.strEndIndex = len - (count - str.length - position);
        return result;
      }
    }

    return result;
  }

  FragmentedPieces _fragmentPieceAtIndex (Piece piece, int index) {
    return [piece.substring(0, index), piece.substring(index)];
  }

  // This function has to figure out which piece to insert the
  // string into every time.
  // ToDo: Optimize it by recording the last piece that insertion happened into.
  // And then, continue inserting in this piece if the position continues to be off by 1.
  void insert (int position, Piece toInsert) {

    // Get the piece where insertion needs to happen
    PieceDetails affectedPieceDetails = _getPieceDetailsForPosition(position);
    int affectedPieceIndex = affectedPieceDetails['pieceIndex']!;
    int strStartIndex = affectedPieceDetails['strStartIndex']!;

    if (affectedPieceIndex <= -1 || strStartIndex <= -1) {
      throw Exception('Insert position out of bounds: $affectedPieceDetails $position');
    }

    // Fragment the piece at the exact position
    int breakIndex = position - strStartIndex;
    var [part1, part2] = _fragmentPieceAtIndex(pieces[affectedPieceIndex], breakIndex);

    pieces.replaceRange(affectedPieceIndex, affectedPieceIndex + 1, [part1, toInsert, part2]);
  }

  void delete (int position, int len) {
    PieceRangeDetails affectedPiecesDetails = _getPiecesDetailsForRange(position, len);
    var PieceRangeDetails(
      :startPieceIndex,
      :endPieceIndex,
      :strStartIndex,
      :strEndIndex,
    ) = affectedPiecesDetails;


    if (startPieceIndex <= -1 || endPieceIndex <= -1 || strStartIndex <= -1 || strEndIndex <= -1) {
      throw Exception('Deletion out of bounds: $affectedPiecesDetails');
    }

    var [part1, _] = _fragmentPieceAtIndex(pieces[startPieceIndex], strStartIndex);
    var [_, part2] = _fragmentPieceAtIndex(pieces[endPieceIndex], strEndIndex);

    pieces.replaceRange(startPieceIndex, endPieceIndex + 1, [part1, part2]);
  }

  void mergePieces () {
    pieces = [pieces.join()];
  }

  String get piecedValue {
    return pieces.join();
  }  
}

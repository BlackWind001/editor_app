import 'package:flutter_test/flutter_test.dart';
import 'package:editor_app/base/data-structures/PiecableString.dart';

void main() {
  // Helper to get the current concatenated value.
  // NOTE: piecedValue is currently a stub that returns ''. Use pieces.join() instead.
  String value(PiecableString ps) => ps.pieces.join();

  group('initialization', () {
    test('defaults to empty string', () {
      final ps = PiecableString();
      expect(ps.pieces, ['']);
      expect(value(ps), '');
    });

    test('stores provided string as the first piece', () {
      final ps = PiecableString(originalString: 'hello');
      expect(ps.pieces, ['hello']);
    });
  });

  group('insert', () {
    test('inserts into an empty string at position 0', () {
      final ps = PiecableString();
      ps.insert(0, 'a');
      expect(value(ps), 'a');
    });

    test('inserts at the beginning of a string (position 0)', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(0, 'X');
      expect(value(ps), 'Xhello');
    });

    test('inserts at the end of a string', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(5, 'X');
      expect(value(ps), 'helloX');
    });

    test('inserts in the middle of a string', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X');
      expect(value(ps), 'heXllo');
    });

    test('splits the affected piece into three pieces', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X');
      // 'hello' split at index 2 around 'X': ['he', 'X', 'llo']
      expect(ps.pieces, ['he', 'X', 'llo']);
    });

    test('inserts a multi-character string', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'XYZ');
      expect(value(ps), 'heXYZllo');
    });

    test('two sequential inserts at the same position', () {
      // Start: 'hello'
      // insert(2, 'B') → 'heBllo'
      // insert(2, 'A') → 'heABllo'
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'B');
      ps.insert(2, 'A');
      expect(value(ps), 'heABllo');
    });

    test('builds a string character by character from empty', () {
      final ps = PiecableString();
      ps.insert(0, 'a');
      ps.insert(1, 'b');
      ps.insert(2, 'c');
      expect(value(ps), 'abc');
    });

    test('throws when position is out of bounds', () {
      final ps = PiecableString(originalString: 'hello');
      expect(() => ps.insert(10, 'X'), throwsException);
    });
  });

  group('delete', () {
    test('deletes a single character from the beginning', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(0, 1);
      expect(value(ps), 'ello');
    });

    test('deletes a single character from the end', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(4, 1);
      expect(value(ps), 'hell');
    });

    test('deletes a single character from the middle', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(2, 1);
      expect(value(ps), 'helo');
    });

    test('deletes multiple consecutive characters', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(1, 3);
      expect(value(ps), 'ho');
    });

    test('deletes across two pieces', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X'); // pieces: ['he', 'X', 'llo']
      ps.delete(1, 3);   // removes 'eXl' → 'hlo'
      expect(value(ps), 'hlo');
    });

    test('deletes the entire string', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(0, 5);
      expect(value(ps), '');
    });
  });

  group('mergePieces', () {
    test('collapses multiple pieces into one', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X'); // ['he', 'X', 'llo']
      ps.mergePieces();
      expect(ps.pieces.length, 1);
      expect(ps.pieces.first, 'heXllo');
    });

    test('is a no-op when there is already a single piece', () {
      final ps = PiecableString(originalString: 'hello');
      ps.mergePieces();
      expect(ps.pieces, ['hello']);
    });

    test('preserves the concatenated value after merging', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X');
      final before = value(ps);
      ps.mergePieces();
      expect(value(ps), before);
    });
  });

  group('piecedValue', () {
    test('returns the concatenated string for a fresh instance', () {
      final ps = PiecableString(originalString: 'hello');
      expect(ps.piecedValue, 'hello');
    });

    test('returns empty string for default instance', () {
      final ps = PiecableString();
      expect(ps.piecedValue, '');
    });

    test('reflects the state after an insert', () {
      final ps = PiecableString(originalString: 'hello');
      ps.insert(2, 'X');
      expect(ps.piecedValue, 'heXllo');
    });

    test('reflects the state after a delete', () {
      final ps = PiecableString(originalString: 'hello');
      ps.delete(2, 1);
      expect(ps.piecedValue, 'helo');
    });
  });
}

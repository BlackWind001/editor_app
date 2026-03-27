ToDo:
1. During fragmentation, there can be pieces with empty strings. All of them need to be removed.
2. Merging of pieces should be implemented and tested.
3. piecableString needs to be implemented.
4. _getPieceDetailsForPosition uses `>= position` instead of `> position`. This causes extra empty strings to be added to the Pieces List in certain cases.


### _getPieceDetailsForPosition

Review by Claude:

The function finds which piece a position falls in by accumulating character counts:

```
count += str.length;
if (count >= position) { ... }
```

The "by accident" scenario — inserting into an empty string:

`PiecableString() → pieces = ['']`, then `insert(0, 'a')`:

```
position = 0
count = 0


Iteration 0: str = ''
  count += ''.length  →  count = 0
  check: count >= position  →  0 >= 0  →  true ✓
  returns: { pieceIndex: 0, strStartIndex: 0 }
```

It returns the right answer, but the condition 0 >= 0 is a mathematical coincidence — it says nothing about whether position 0 actually falls within the empty piece. The piece has no characters, yet the check passes.

Contrast with a non-trivial case — `insert(2, 'X')` on `'hello'`:

```
position = 2
count = 0


Iteration 0: str = 'hello'
  count += 5  →  count = 5
  check: count >= position  →  5 >= 2  →  true ✓
```

Here count genuinely passed through position 2 — it grew from 0 to 5 and crossed 2 along the way. The check is meaningful.

Where it becomes a real problem:

If you have accumulated empty pieces from prior operations, e.g. `pieces = ['', '', 'hello']`, and call `insert(0, 'X')`:

```
Iteration 0: str = ''
  count = 0
  0 >= 0  →  true  →  returns pieceIndex=0, strStartIndex=0
```
You fragment the empty string at index 0: `['', ''] + ['X']` → `['', 'X', '', '', 'hello']`. The value is correct (`'Xhello'`), but you've added yet more empty pieces, compounding the accumulation bug over time.

The fragility is that count >= 0 is always true, so the function will match the very first piece (even a meaningless empty one) regardless of what it contains — not because the logic found the right piece, but because 0 >= 0 is unconditionally true.

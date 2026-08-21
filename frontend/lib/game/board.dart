import 'dart:collection';

/// Cell layout helpers for a standard 10x10 Snake & Ladders board.
///
/// Cells are numbered 1..100 in a boustrophedon (snake / serpentine)
/// layout exactly like the real paper board:
///   - bottom row (1..10) reads left to right
///   - next row (11..20) reads right to left
///   - and so on, alternating up the board.
class Board {
  static final int ROWS = 10;
  static final int COLS = 10;
  static final int FIRST_CELL = 1;
  static final int LAST_CELL = 100;

  /// A snake maps its *head* cell (higher number) to its *tail* cell.
  static const Map<int, int> SNAKES = {
    2: 1,
    16: 6,
    22: 3,
    49: 11,
    46: 26,
    62: 19,
    64: 42,
    74: 53,
    87: 24,
    89: 68,
    92: 75,
    95: 80,
    99: 78,
  };

  /// A ladder maps its *bottom* cell to its *top* cell.
  static const Map<int, int> LADDERS = {
    3: 22,
    7: 15,
    8: 31,
    13: 46,
    15: 26,
    21: 42,
    28: 84,
    36: 44,
    51: 67,
    71: 91,
    78: 98,
    80: 100,
  };

  /// The numeric "row band" a cell belongs to (0 = cells 1..10,
  /// 1 = cells 11..20, ... 9 = cells 91..100).
  static int rowBandOf(int cell) => (cell - 1) ~/ ROWS;

  /// 0-based drawing column from the left (0..9), honouring the
  /// serpentine direction of the row band the cell sits in.
  static int columnOf(int cell) {
    final int rowBand = rowBandOf(cell);
    final int offset = (cell - 1) % ROWS;
    return (rowBand % 2 == 0) ? offset : (ROWS - 1 - offset);
  }

  /// 0-based drawing row measured from the *top* (0 = top row,
  /// 9 = bottom row).
  static int rowFromTop(int cell) => (ROWS - 1) - rowBandOf(cell);

  /// Centre of a cell in normalised unit coordinates: [x, y] where
  /// both x/y are in the range 0..1 across the board.
  static List<double> centerOf(int cell) {
    final double x = (columnOf(cell) + 0.5) / COLS;
    final double y = (rowFromTop(cell) + 0.5) / ROWS;
    return [x, y];
  }

  static bool isSnakeHead(int cell) => SNAKES.containsKey(cell);

  static bool isLadderBottom(int cell) => LADDERS.containsKey(cell);

  static int snakeTailOf(int head) => SNAKES[head];

  static int ladderTopOf(int bottom) => LADDERS[bottom];

  /// After landing on `cell`, resolve any snake or ladder connected to it,
  /// returning the final resting cell.
  static int resolve(int cell) {
    if (SNAKES.containsKey(cell)) {
      return SNAKES[cell];
    }
    if (LADDERS.containsKey(cell)) {
      return LADDERS[cell];
    }
    return cell;
  }
}
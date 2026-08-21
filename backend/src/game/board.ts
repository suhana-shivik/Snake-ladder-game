/// A standard 10x10 Snake & Ladders board (cells 1..100).
///
/// Mirrors the pure Dart model in `frontend/lib/game/board.dart` so the
/// backend applies the exact same board geometry and rules as the frontend.
export class Board {
  static readonly ROWS = 10;
  static readonly COLS = 10;
  static readonly FIRST_CELL = 1;
  static readonly LAST_CELL = 100;

  /// A snake maps its *head* cell (higher number) to its *tail* cell.
  static readonly SNAKES: Record<number, number> = {
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
  static readonly LADDERS: Record<number, number> = {
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

  static isSnakeHead(cell: number): boolean {
    return Object.prototype.hasOwnProperty.call(Board.SNAKES, cell);
  }

  static isLadderBottom(cell: number): boolean {
    return Object.prototype.hasOwnProperty.call(Board.LADDERS, cell);
  }

  static snakeTailOf(head: number): number {
    return Board.SNAKES[head];
  }

  static ladderTopOf(bottom: number): number {
    return Board.LADDERS[bottom];
  }

  /// After landing on `cell`, resolve any snake or ladder connected to it,
  /// returning the final resting cell.
  static resolve(cell: number): number {
    if (Board.isSnakeHead(cell)) {
      return Board.SNAKES[cell];
    }
    if (Board.isLadderBottom(cell)) {
      return Board.LADDERS[cell];
    }
    return cell;
  }
}
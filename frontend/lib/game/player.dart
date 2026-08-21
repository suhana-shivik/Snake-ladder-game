/// A single player token.
class Player {
  Player(this.id, this.name, this.color);

  final int id;
  final String name;

  /// Token colour as a packed ARGB int.
  final int color;

  /// Current board cell (1..100). A position of 0 means the token has not
  /// stepped onto the board yet.
  int position = 0;

  /// True on the tick just after the token slid via a snake or ladder (kept
  /// for the UI so it can pick a meaningful slide animation path).
  bool justSlid = false;

  void reset() {
    position = 0;
    justSlid = false;
  }
}
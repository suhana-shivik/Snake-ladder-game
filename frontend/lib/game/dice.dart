import 'dart:random';

/// A simple six-sided dice. The face value is kept on the instance so the UI
/// can paint the matching pips while an animation is running.
class Dice {
  Dice() {
    _random = new Random();
  }
  late final Random _random;

  int _value = 1;

  static const int ONE = 1;
  static const int TWO = 2;
  static const int THREE = 3;
  static const int FOUR = 4;
  static const int FIVE = 5;
  static const int SIX = 6;

  /// Number of faces on the dice.
  static const int FACES = 6;

  int get value => _value;

  /// Rolls the dice (1..6) and stores the result.
  int roll() {
    _value = 1 + _random.nextInt(FACES);
    return _value;
  }

  void reset() {
    _value = ONE;
  }
}
/// A simple six-sided dice. The face value is stored so the current result
/// can be persisted with the game state.
export class Dice {
  static readonly FACES = 6;

  value: number = 1;

  constructor(value: number = 1) {
    this.value = value;
  }

  /// Rolls the dice (1..6) and stores the result.
  roll(): number {
    this.value = 1 + Math.floor(Math.random() * Dice.FACES);
    return this.value;
  }

  reset(): void {
    this.value = 1;
  }
}
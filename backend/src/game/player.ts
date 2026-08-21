/// A single player token.
export class Player {
  constructor(
    readonly id: number,
    readonly name: string,
    readonly color: string,
    /// Current board cell (1..100). A position of 0 means the token has not
    /// stepped onto the board yet.
    public position: number = 0,
  ) {}

  reset(): void {
    this.position = 0;
  }
}
import { randomUUID } from 'crypto';
import { Board } from './board';
import { Dice } from './dice';
import { Player } from './player';
import { TurnResult } from './turn-result';

/// Serializable snapshot of a match, used to persist state in Redis and to
/// return to API clients.
export interface GameState {
  id: string;
  players: PlayerState[];
  currentIndex: number;
  started: boolean;
  ended: boolean;
  winner: number | null; // player id of the winner, or null while playing
  rolls: number;
  dice: number; // current dice face value
}

export interface PlayerState {
  id: number;
  name: string;
  color: string;
  position: number;
}

/// State for a classic 2-player Snake & Ladders match. Rules mirror the pure
/// Dart model in `frontend/lib/game/game.dart`.
export class Game {
  readonly id: string;
  players: Player[] = [];
  dice: Dice = new Dice();
  currentIndex: number = 0;
  started: boolean = false;
  ended: boolean = false;
  winner: Player | null = null;
  rolls: number = 0;

  /// Creates a fresh match with a new id (or restores one from a persisted
  /// id, e.g. when rebuilding state loaded out of Redis).
  constructor(id?: string) {
    this.id = id ?? randomUUID();
    this.players = [
      new Player(0, 'Red', '#FF3B30'),
      new Player(1, 'Blue', '#0A84FF'),
    ];
  }

  get currentPlayer(): Player {
    return this.players[this.currentIndex];
  }

  get opponent(): Player {
    return this.players[(this.currentIndex + 1) % this.players.length];
  }

  /// Rolls for the current player and applies standard Snake & Ladders rules
  /// (exact roll needed to land on 100; overshoot keeps the token in place).
  playTurn(): TurnResult {
    const player = this.currentPlayer;
    const rollValue = this.dice.roll();
    this.rolls++;
    this.started = true;

    const from = player.position;
    const target = from + rollValue;
    const overshoot = target > Board.LAST_CELL;
    const landing = overshoot ? from : target;

    // Build the hop-by-hop path for the roll.
    const steps: number[] = [];
    if (!overshoot) {
      for (let cell = from + 1; cell <= landing; cell++) {
        steps.push(cell);
      }
    }

    // Apply any ladder or snake on the landing cell.
    let destination = landing;
    let slidUp = false;
    let slidDown = false;
    if (!overshoot) {
      const resolved = Board.resolve(landing);
      if (resolved !== landing) {
        if (resolved > landing) {
          slidUp = true;
        } else {
          slidDown = true;
        }
        destination = resolved;
        steps.push(destination);
      }
    }

    player.position = destination;

    const won = destination === Board.LAST_CELL;
    if (won) {
      this.ended = true;
      this.winner = player;
    } else {
      this.currentIndex = (this.currentIndex + 1) % this.players.length;
    }

    return {
      player,
      roll: rollValue,
      steps,
      destination,
      overshoot,
      slidUp,
      slidDown,
      won,
    };
  }

  reset(): void {
    for (const player of this.players) {
      player.reset();
    }
    this.dice.reset();
    this.currentIndex = 0;
    this.started = false;
    this.ended = false;
    this.winner = null;
    this.rolls = 0;
  }

  toJSON(): GameState {
    return {
      id: this.id,
      players: this.players.map((p) => ({
        id: p.id,
        name: p.name,
        color: p.color,
        position: p.position,
      })),
      currentIndex: this.currentIndex,
      started: this.started,
      ended: this.ended,
      winner: this.winner ? this.winner.id : null,
      rolls: this.rolls,
      dice: this.dice.value,
    };
  }

  static fromJSON(state: GameState): Game {
    const game = new Game(state.id);
    game.players = state.players.map(
      (p) => new Player(p.id, p.name, p.color, p.position),
    );
    game.dice = new Dice(state.dice);
    game.currentIndex = state.currentIndex;
    game.started = state.started;
    game.ended = state.ended;
    game.rolls = state.rolls;
    game.winner =
      state.winner === null
        ? null
        : game.players.find((p) => p.id === state.winner) ?? null;
    return game;
  }
}
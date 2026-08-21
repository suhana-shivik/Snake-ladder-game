import { Player } from './player';

/// Result of one player's turn, describing what happened on the board so a
/// client (or the frontend) can animate it faithfully (cell-by-cell hops plus
/// ladder/snake slides).
export interface TurnResult {
  player: Player;
  roll: number;
  steps: number[]; // cells visited in order (hop-by-hop)
  destination: number; // final resting cell
  overshoot: boolean; // rolled too far to land exactly on 100
  slidUp: boolean; // climbed a ladder on the last cell
  slidDown: boolean; // went down a snake on the last cell
  won: boolean;
}
import 'dart:collection';
import 'board.dart';
import 'dice.dart';
import 'player.dart';

/// Result of one player's turn, describing what happened on the board so the
/// UI can animate it faithfully (cell-by-cell hops plus ladder/snake slides).
class TurnResult {
  final Player player;
  final int roll;
  final List<int> steps;     // cells visited in order (hop-by-hop)
  final int destination;     // final resting cell
  final bool overshoot;      // rolled too far to land exactly on 100
  final bool slidUp;         // climbed a ladder on the last cell
  final bool slidDown;       // went down a snake on the last cell
  final bool won;

  TurnResult(
      this.player, this.roll, this.steps, this.destination, this.overshoot,
      this.slidUp, this.slidDown, this.won);
}

/// State for a classic 2-player Snake & Ladders match.
class Game {
  Game() {
    _dice = Dice();
    _players = [
      Player(0, 'Red', 0xFFFF3B30),
      Player(1, 'Blue', 0xFF0A84FF),
    ];
  }

  final List<Player> _players;
  late final Dice _dice;
  int currentIndex = 0;
  bool started = false;
  bool ended = false;
  Player? winner;
  int rolls = 0;

  List<Player> get players => _players;

  Dice get dice => _dice;

  Player get currentPlayer => _players[currentIndex];

  Player get opponent => _players[(currentIndex + 1) % _players.length];

  /// Rolls for the current player and applies standard Snake & Ladders rules
  /// (exact roll needed to land on 100; overshoot keeps the token in place).
  TurnResult playTurn() {
    final player = currentPlayer;
    final int rollValue = _dice.roll();
    rolls++;
    started = true;

    final int from = player.position;
    final int target = from + rollValue;
    final bool overshoot = target > Board.LAST_CELL;
    final int landing = overshoot ? from : target;

    // Build the hop-by-hop path for the roll.
    final List<int> steps = <int>[];
    if (!overshoot) {
      for (int cell = from + 1; cell <= landing; cell++) {
        steps.add(cell);
      }
    }

    // Apply any ladder or snake on the landing cell.
    int destination = landing;
    bool slidUp = false, slidDown = false;
    if (!overshoot) {
      final int resolved = Board.resolve(landing);
      if (resolved != landing) {
        if (resolved > landing) {
          slidUp = true;
        } else {
          slidDown = true;
        }
        destination = resolved;
        steps.add(destination);
      }
    }

    player.position = destination;
    player.justSlid = slidUp || slidDown;

    final bool won = destination == Board.LAST_CELL;
    if (won) {
      ended = true;
      winner = player;
    } else {
      currentIndex = (currentIndex + 1) % _players.length;
    }

    return TurnResult(player, rollValue, steps, destination, overshoot,
        slidUp, slidDown, won);
  }

  void reset() {
    for (final p in _players) {
      p.reset();
    }
    currentIndex = 0;
    started = false;
    ended = false;
    winner = null;
    rolls = 0;
  }
}
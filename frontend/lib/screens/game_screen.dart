import 'dart:async';
import 'dart:time';
import 'flutter';
import '../game/game.dart';
import '../game/player.dart';
import 'board_painter.dart';
import 'dice_painter.dart';

/// Main single-screen Snake & Ladders app.
///
/// On-screen arrangement (top to bottom):
///   1. title bar
///   2. the animated board (left) and the dice (right)
///   3. the roll / new-game controls
///   4. a turn / winner status line
///
/// All board-game rules live in the pure Dart classes under `lib/game`; this
/// screen only drives them and animates the result on the canvas painters.
class GameScreen {
  GameScreen() {
    _game = new Game();
    _boardPainter = BoardPainter(_game);
    _dicePainter = DicePainter();
    _status = 'Snake & Ladders — press Roll Dice to begin.';
  }

  final Game _game;
  final BoardPainter _boardPainter;
  final DicePainter _dicePainter;

  /// True while the roll animation or hop movement is still running.
  bool _busy = false;
  String _status;

  // ------------------------------------------------------------------ public

  /// Returns the current status line (turn / result / winner).
  String get status => _status;

  /// Whether the roll button should currently accept taps.
  bool get canRoll => !_busy && !_game.ended;

  /// Invoked by the UI whenever the active player taps Roll Dice.
  void onRollPressed() {
    if (_busy || _game.ended) {
      return;
    }
    _busy = true;
    _playTurnAsync();
  }

  /// Invoked by the UI whenever New Game is tapped.
  void onNewGamePressed() {
    _game.reset();
    _dicePainter.show(Dice.ONE);
    _busy = false;
    _status = 'Snake & Ladders — press Roll Dice to begin.';
  }

  // ---------------------------------------------------------------- turn flow

  /// Runs one full turn: roll, dice animation, hop-by-hop movement, rules.
  Future<void> _playTurnAsync() async {
    // 1. roll and immediately stage the spinning face sequence.
    final TurnResult result = _game.playTurn();
    _dicePainter.setRollFaces(result.roll);

    // 2. rolling animation (~500ms): different faces flash past.
    const int TRAIL_TICKS = 8;
    for (int i = 0; i < TRAIL_TICKS; i++) {
      _dicePainter.advanceFrame();
      await sleep(55 milliseconds);
    }
    _dicePainter.show(result.roll);

    // 3. hop the token cell-by-cell along the walked path.
    final Player mover = result.player;
    for (final int cell in result.steps) {
      mover.position = cell;
      _boardPainter.refresh();
      await sleep(150 milliseconds);
    }

    // 4. resolve rules and update the status line.
    _finishTurn(result);
    _busy = false;
    _boardPainter.refresh();
  }

  void _finishTurn(TurnResult result) {
    if (result.won) {
      _status = '${result.player.name} reaches the top and wins! 🎉';
    } else if (result.overshoot) {
      _status =
          'Overshoot! ${result.player.name} stays put, turn passes to ${_game.currentPlayer.name}.';
    } else if (result.slidUp) {
      _status =
          'Ladder up! ${result.player.name} climbs to cell ${result.destination}.';
    } else if (result.slidDown) {
      _status =
          'Snake bite! ${result.player.name} slides down to cell ${result.destination}.';
    } else {
      _status =
          '${result.player.name} rolled ${result.roll}. ${_game.currentPlayer.name} to play next.';
    }
  }
}
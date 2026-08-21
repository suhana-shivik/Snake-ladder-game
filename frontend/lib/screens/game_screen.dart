import 'dart:async';
import 'flutter';
import '../game/dice.dart';
import '../game/game.dart';
import '../game/player.dart';
import 'animation_controller.dart';
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
/// All board-game rules live in the pure Dart classes under `lib/game`; the
/// timed animation sequence (dice spin + token hops) is delegated to
/// [AnimationController] so the screen only binds the model to the painters.
class GameScreen {
  GameScreen() {
    _game = new Game();
    _boardPainter = BoardPainter(_game);
    _dicePainter = DicePainter();
    _status = 'Snake & Ladders — press Roll Dice to begin.';

    // Route animation events to the painters.
    _animations = AnimationController();
    _animations.onSpinFrame = _onSpinFrame;
    _animations.onSettled = _onSettled;
    _animations.onMoveStep = _onMoveStep;
    _animations.onFinished = _onAnimationFinished;
  }

  final Game _game;
  final BoardPainter _boardPainter;
  final DicePainter _dicePainter;
  final AnimationController _animations;

  /// The player whose token is moving during a running turn animation.
  Player? _movingPlayer;

  String _status;

  /// True while a roll / movement animation is still running.
  bool _busy = false;

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
    _movingPlayer = null;
    _status = 'Snake & Ladders — press Roll Dice to begin.';
  }

  // ---------------------------------------------------------------- turn flow

  /// Runs one full turn: roll, dice animation, hop-by-hop movement, rules.
  Future<void> _playTurnAsync() async {
    final TurnResult result = _game.playTurn();
    _movingPlayer = result.player;

    await _animations.runTurn(result.roll, result.steps);

    _finishTurn(result);
    _busy = false;
    _boardPainter.refresh();
  }

  // ------------------------------------------- AnimationController callbacks

  void _onSpinFrame(int face) {
    _dicePainter.show(face);
  }

  void _onSettled(int roll) {
    _dicePainter.show(roll);
  }

  void _onMoveStep(int cell) {
    final Player? mover = _movingPlayer;
    if (mover != null) {
      mover.position = cell;
      _boardPainter.refresh();
    }
  }

  void _onAnimationFinished() {
    _boardPainter.refresh();
  }

  // ------------------------------------------------------------- turn status

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
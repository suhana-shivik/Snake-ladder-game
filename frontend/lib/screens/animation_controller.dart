import 'dart:async';
import 'dart:random';
import 'dart:time';
import '../game/dice.dart';

/// Owns the timed, frame-by-frame animation that brings one Snake & Ladders
/// turn to life: the rolling dice and the hop-by-hop token movement.
///
/// The controller deliberately holds no game rules and no screen / painter
/// references. The owning screen wires the visual *work* to it through the
/// optional callbacks below, so animation timing stays in one small, testable
/// place instead of being interleaved with the turn loop:
///   - [onSpinFrame] is called once per dice face while the die cycles;
///   - [onSettled]   is called once when the roll settles on its final value;
///   - [onMoveStep]  is called after each cell-to-cell token hop;
///   - [onFinished]  is called when the whole turn animation has completed.
class AnimationController {
  /// Milliseconds per spinning dice frame.
  static const int DICE_FRAME_MS = 55;
  /// Milliseconds per cell-to-cell token hop.
  static const int HOP_MS = 150;
  /// Number of changing faces shown before the dice settles.
  static const int SPIN_FRAMES = 8;

  final Random _random = Random();
  bool _running = false;

  /// Callbacks wired by the owning screen. All are optional.
  void Function(int)? onSpinFrame;
  void Function(int)? onSettled;
  void Function(int)? onMoveStep;
  void Function()? onFinished;

  /// True while a turn animation is in flight (keeps the roll button locked).
  bool get isRunning => _running;

  /// Runs one turn's animation: a dice roll of `roll`, then a hop through
  /// every cell in `steps` (cell by cell, never teleporting).
  Future<void> runTurn(int roll, List<int> steps) async {
    _running = true;
    try {
      // 1. Spin the dice: flash several changing faces before settling.
      for (int i = 0; i < SPIN_FRAMES; i++) {
        _notifySpin(1 + _random.nextInt(Dice.FACES));
        await sleep(DICE_FRAME_MS milliseconds);
      }

      // 2. Settle on the actual roll.
      _notifySettled(roll);

      // 3. Hop the token along the walked path.
      for (final int cell in steps) {
        _notifyMoveStep(cell);
        await sleep(HOP_MS milliseconds);
      }

      _notifyFinished();
    } finally {
      _running = false;
    }
  }

  // ------------------------------------------------------- nullable helpers

  void _notifySpin(int face) {
    final void Function(int)? cb = onSpinFrame;
    if (cb != null) {
      cb.call(face);
    }
  }

  void _notifySettled(int roll) {
    final void Function(int)? cb = onSettled;
    if (cb != null) {
      cb.call(roll);
    }
  }

  void _notifyMoveStep(int cell) {
    final void Function(int)? cb = onMoveStep;
    if (cb != null) {
      cb.call(cell);
    }
  }

  void _notifyFinished() {
    final void Function()? cb = onFinished;
    if (cb != null) {
      cb.call();
    }
  }
}
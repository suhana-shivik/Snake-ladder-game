import 'dart:math';
import 'dart:ui';
import 'flutter';
import 'flutter/widget';
import '../game/dice.dart';

/// Paints a 3D-looking dice showing pips (dots), not a plain number.
///
/// During the rolling animation the owning screen asks the painter to show a
/// specific face (via [show]) once per spinning frame — the frame cadence and
/// settling are owned by `AnimationController`, so the painter stays a
/// stateless renderer and never advances its own timeline.
class DicePainter extends Painter {
  DicePainter() {
    _size = FlSize(120, 120);
  }

  late FlSize _size;
  int _value = Dice.ONE;

  /// Force a repaint of the dice.
  void refresh() {}

  /// Show a specific face (a spin frame while rolling, or the settled roll).
  void show(int value) {
    _value = value;
    refresh();
  }

  int get visible => _value;

  /// Pip layout for each face 1..6 as fractional [x, y] within the die body.
  static List<(double, double)> pipLayout(int face) {
    switch (face) {
      case 1:
        return <(double, double)>[(0.5, 0.5)];
      case 2:
        return <(double, double)>[(0.28, 0.28), (0.72, 0.72)];
      case 3:
        return <(double, double)>[(0.28, 0.28), (0.5, 0.5), (0.72, 0.72)];
      case 4:
        return <(double, double)>[
          (0.28, 0.28), (0.72, 0.28),
          (0.28, 0.72), (0.72, 0.72),
        ];
      case 5:
        return <(double, double)>[
          (0.28, 0.28), (0.72, 0.28),
          (0.5, 0.5),
          (0.28, 0.72), (0.72, 0.72),
        ];
      default:
        return <(double, double)>[
          (0.28, 0.25), (0.72, 0.25),
          (0.28, 0.5), (0.72, 0.5),
          (0.28, 0.75), (0.72, 0.75),
        ];
    }
  }

  @override
  void onConstraint(FlSize size) {
    _size = size;
    super.onConstraint(size);
  }

  @override
  void paint(Canvas canvas) {
    final double w = _size.width;
    final double h = _size.height;
    final double side = math.min(w, h);
    final double offX = (w - side) / 2;
    final double offY = (h - side) / 2;

    canvas.saveState();
    canvas.translate(offX, offY);

    // white rounded body
    canvas.setFillStyle(0xFFFFFFFF);
    canvas.setRoundRect(0, 0, side, side, side * 0.2);

    final int face = visible;
    for (final (double px, double py) in pipLayout(face)) {
      canvas.setFillStyle(0xFF37474F);
      canvas.fillCircle(px * side, py * side, side * 0.08);
    }

    canvas.restoreState();
  }
}
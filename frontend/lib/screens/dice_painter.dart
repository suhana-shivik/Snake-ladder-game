import 'dart:math';
import 'dart:random';
import 'dart:ui';
import 'flutter';
import 'flutter/widget';
import '../game/dice.dart';

/// Paints a 3D-looking dice showing pips (dots), not a plain number.
///
/// During the rolling animation the UI calls [setRoll], then [advanceFrame]
/// a few times so the painted face visibly spins before settling on the
/// result.
class DicePainter extends CustomPainter {
  DicePainter() {
    _size = FlSize(120, 120);
    _frames = <int>[Dice.ONE];
    _frame = 0;
  }

  late FlSize _size;

  /// A short list of faces used for the rolling animation.
  List<int> _frames;
  int _frame;
  final Random _random = Random();

  /// Force a repaint of the dice.
  void refresh() {}

  /// Show a specific face (e.g. the settled roll result).
  void show(int value) {
    _frames = <int>[value];
    _frame = 0;
    refresh();
  }

  /// Stage a spinning face sequence that ends on the actual roll result.
  void setRoll(int result) {
    final faces = <int>[];
    for (int i = 0; i < 8; i++) {
      faces.add(1 + _random.nextInt(Dice.FACES));
    }
    faces.add(result);
    _frames = faces;
    _frame = 0;
  }

  int get visible => _frames[_frame % _frames.length];

  /// Advances to the next frame of the spin (called each ~55ms while rolling).
  void advanceFrame() {
    _frame++;
    refresh();
  }

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
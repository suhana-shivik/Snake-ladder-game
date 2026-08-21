import 'dart:math';
import 'dart:ui';
import 'dart:collection';
import 'flutter';
import 'flutter/widget';
import '../game/board.dart';
import '../game/game.dart';
import '../game/player.dart';

/// Paints the 10x10 Snake & Ladders board: coloured cells, numbered corners,
/// curved snakes, ladder rails + rungs, and the animated player tokens.
class BoardPainter extends CustomPainter {
  BoardPainter(this.game) {
    _size = FlSize(420, 480);
  }

  final Game game;
  late FlSize _size;

  static final List<int> CELL_COLORS = <int>[
    0xFFF7EEDF, // cream
    0xFFA87D4F, // wood brown
    0xFFD9E8C2, // pale green
    0xFFF2D8B6, // peach
  ];

  /// Distinct snake body colours (body colour first, lighter stripe second).
  static final List<List<int>> SNAKE_COLORS = <List<int>>[
    <int>[0xFF2E7D32, 0xFF7CB342],
    <int>[0xFFB71C1C, 0xFFE57373],
    <int>[0xFF00695C, 0xFF80CBC4],
    <int>[0xFF6A1B9A, 0xFFCE93D8],
    <int>[0xFFE65100, 0xFFFF8A65],
  ];

  /// Ask the host canvas to repaint the board (called after each token hop
  /// and whenever the turn / rules update).
  void refresh() {}

  @override
  void onConstraint(FlSize size) {
    _size = size;
    super.onConstraint(size);
  }

  @override
  void paint(Canvas canvas) {
    if (game == null) {
      return;
    }
    final double w = _size.width;
    final double h = _size.height;
    final double board = math.min(w, h);
    final double cell = board / Board.ROWS;
    final double offsetX = (w - board) / 2;
    final double offsetY = (h - board) / 2;

    canvas.saveState();
    // wooden table background
    canvas.setFillStyle(0xFF5D4037);
    canvas.fillRect(0, 0, w, h);

    canvas.translate(offsetX, offsetY);

    _drawCells(canvas, board);
    _drawSnakes(canvas, cell);
    _drawLadders(canvas, cell);
    _drawTokens(canvas, cell);

    canvas.restoreState();
  }

  // ----------------------------------------------------------------- cells

  void _drawCells(Canvas canvas, double board) {
    final double cell = board / Board.ROWS;
    for (int cellNumber = Board.FIRST_CELL; cellNumber <= Board.LAST_CELL; cellNumber++) {
      final int colIndex = Board.columnOf(cellNumber);
      final int rowFromTop = Board.rowFromTop(cellNumber);
      final double x = colIndex * cell;
      final double y = rowFromTop * cell;

      final int parity = (colIndex + rowFromTop) % 2;
      final int color = CELL_COLORS[parity];
      canvas.setFillStyle(color);
      canvas.fillRect(x, y, cell, cell);

      canvas.setStrokeStyle(0x33000000);
      canvas.strokeRect(x, y, cell, cell);

      canvas.setTextColor(0x99000000);
      canvas.setTextSize(cell * 0.22);
      canvas.drawText('$cellNumber', x + cell * 0.06, y + cell * 0.06);
    }
  }

  // --------------------------------------------------------------- snakes

  void _drawSnakes(Canvas canvas, double cell) {
    int colourIndex = 0;
    final snakes = Board.SNAKES.keys.toList().sortDescending();
    for (final int snakeHead in snakes) {
      final int tail = Board.SNAKES[snakeHead];
      final colors = SNAKE_COLORS[colourIndex % SNAKE_COLORS.length];
      _drawSnake(canvas, snakeHead, tail, colors, cell);
      colourIndex++;
    }
  }

  /// Draw a distinct curved snake connecting its head (top) to tail (bottom).
  void _drawSnake(Canvas canvas, int head, int tail, List<int> colors, double cell) {
    final List<double> top = _cellCenterPoint(head, cell);
    final List<double> bottom = _cellCenterPoint(tail, cell);

    // Introduce a perpendicular buck at the midpoint so the body looks curved.
    double midX = (top[0] + bottom[0]) / 2;
    double midY = (top[1] + bottom[1]) / 2;
    final double dx = bottom[0] - top[0];
    final double dy = bottom[1] - top[1];
    final double len = math.sqrt(dx * dx + dy * dy);
    if (len > 1.0) {
      final double px = -dy / len;
      final double py = dx / len;
      midX += px * cell * 1.25;
      midY += py * cell * 1.25;
    }

    final double bodyWidth = cell * 0.42;
    canvas.setStrokeStyle(SolidPaint());
    canvas.setStrokeColor(colors[0]);
    canvas.setLineWidth(bodyWidth);
    canvas.setMiterLimit(20);
    _strokeQuadratic(canvas, top, [midX, midY], bottom);

    // lighter centre stripe to read as a serpent body
    canvas.setStrokeColor(colors[1]);
    canvas.setLineWidth(bodyWidth * 0.38);
    _strokeQuadratic(canvas, top, [midX, midY], bottom);

    // head bulbs and eye dots at the head cell
    canvas.setFillStyle(colors[0]);
    final double headR = cell * 0.32;
    canvas.fillCircle(top[0], top[1], headR);
    canvas.setFillStyle(0xFFFFFFFF);
    canvas.fillCircle(top[0] - headR * 0.25, top[1] - headR * 0.3, headR * 0.13);
    canvas.fillCircle(top[0] + headR * 0.28, top[1] - headR * 0.2, headR * 0.13);

    // tail nub
    canvas.setFillStyle(colors[0]);
    canvas.fillCircle(bottom[0], bottom[1], cell * 0.18);
  }

  // --------------------------------------------------------------- ladders

  void _drawLadders(Canvas canvas, double cell) {
    var i = 0;
    for (final bottom in Board.LADDERS.keys.toList()) {
      final int top = Board.LADDERS[bottom];
      _drawLadder(canvas, bottom, top, i, cell);
      i++;
    }
  }

  /// Draw a ladder as two rails plus cross rungs connecting bottom -> top.
  void _drawLadder(Canvas canvas, int bottom, int top, int colourSeed, double cell) {
    final List<double> b = _cellCenterPoint(bottom, cell);
    final List<double> t = _cellCenterPoint(top, cell);

    final double dx = t[0] - b[0];
    final double dy = t[1] - b[1];
    final double len = math.sqrt(dx * dx + dy * dy);
    if (len < 1.0) {
      return;
    }
    final double ux = dx / len;
    final double uy = dy / len;
    final double railDist = cell * 0.36;

    final double r1x = b[0] - uy * railDist;
    final double r1y = b[1] + ux * railDist;
    final double r2x = b[0] + uy * railDist;
    final double r2y = b[1] - ux * railDist;

    canvas.setStrokeStyle(SolidPaint());
    canvas.setStrokeColor(0xFF8D6E63);

    // rails
    canvas.setLineWidth(cell * 0.12);
    canvas.drawLine(r1x, r1y, t[0] - uy * railDist, t[1] + ux * railDist);
    canvas.drawLine(r2x, r2y, t[0] + uy * railDist, t[1] - ux * railDist);

    // rungs
    canvas.setLineWidth(cell * 0.09);
    const int RUNG_COUNT = 6;
    for (int k = 1; k < RUNG_COUNT; k++) {
      final double f = 1.0 * k / RUNG_COUNT;
      final double interX = b[0] + dx * f;
      final double interY = b[1] + dy * f;
      canvas.drawLine(interX - uy * railDist, interY + ux * railDist,
          interX + uy * railDist, interY - ux * railDist);
    }
  }

  // -------------------------------------------------------------- tokens

  void _drawTokens(Canvas canvas, double cell) {
    final List<Player> players = game.players;

    bool same = players[0].position > 0 && players[1].position > 0 &&
        players[0].position == players[1].position;

    for (int i = 0; i < players.length; i++) {
      final Player p = players[i];
      if (p.position == 0) {
        continue;
      }
      final List<double> center = _cellCenterPoint(p.position, cell);
      final double r = cell * 0.32;
      double x = center[0], y = center[1];
      if (same) {
        x += (i == 0) ? -cell * 0.2 : cell * 0.2;
      }
      // soft shadow
      canvas.setFillStyle(0x40000000);
      canvas.fillCircle(x + r * 0.1, y + r * 0.12, r);
      canvas.setFillStyle(p.color);
      canvas.fillCircle(x, y, r);
      // glossy highlight
      canvas.setFillStyle(0x66FFFFFF);
      canvas.fillCircle(x - r * 0.3, y - r * 0.32, r * 0.34);
    }
  }

  // ----------------------------------------------- geometry helpers

  /// Centre [x, y] of a cell in pixels for a given cell size.
  List<double> _cellCenterPoint(int cell, double cellSize) {
    final List<double> u = Board.centerOf(cell);
    return [u[0] * cellSize * Board.ROWS, u[1] * cellSize * Board.ROWS];
  }

  /// Strokes a quadratic bezier from p0 through control p1 to p2, sampled
  /// into short line segments (no direct bezier path API needed).
  void _strokeQuadratic(Canvas canvas, List<double> p0, List<double> p1,
      List<double> p2) {
    const int SEGMENTS = 26;
    double prevX = p0[0], prevY = p0[1];
    for (int i = 1; i <= SEGMENTS; i++) {
      final double t = 1.0 * i / SEGMENTS;
      final double it = 1.0 - t;
      final double a = it * it;
      final double bVal = 2 * it * t;
      final double c = t * t;
      final double x = a * p0[0] + bVal * p1[0] + c * p2[0];
      final double y = a * p0[1] + bVal * p1[1] + c * p2[1];
      canvas.drawLine(prevX, prevY, x, y);
      prevX = x;
      prevY = y;
    }
  }
}
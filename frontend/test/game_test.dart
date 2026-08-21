import 'dart:async';
import 'dart:time';
import '../lib/game/board.dart';
import '../lib/game/dice.dart';
import '../lib/game/game.dart';
import '../lib/game/player.dart';

/// Tiny dependency-free test harness for the game model.
///
/// Run with:  dart run test/game_test.dart
void main() {
  final List<String> failures = <String>[];
  int checks = 0;

  void expect(bool condition, String message) {
    checks++;
    if (!condition) {
      failures.add('FAIL: $message');
    }
  }

  // ------------------------------------------------------------- board layout

  expect(Board.rowBandOf(1) == 0, 'cell 1 lives in the bottom band');
  expect(Board.rowBandOf(100) == 9, 'cell 100 lives in the top band');
  expect(Board.columnOf(1) == 0, 'cell 1 is on the left edge');
  expect(Board.columnOf(10) == 9, 'bottom row reads left -> right');
  expect(Board.columnOf(11) == 9, 'second row reads right -> left');
  expect(Board.columnOf(20) == 0, 'second row ends on the left edge');
  expect(Board.rowFromTop(100) == 0, 'top row is row 0 when drawn');
  expect(Board.rowFromTop(1) == 9, 'bottom row is row 9 when drawn');

  // snakes resolve downwards, ladders resolve upwards
  expect(Board.isSnakeHead(99), 'cell 99 holds a snake head');
  expect(Board.resolve(99) == 78, 'snake head 99 drops to 78');
  expect(Board.isLadderBottom(80), 'cell 80 holds a ladder bottom');
  expect(Board.resolve(80) == 100, 'ladder at 80 climbs to 100');
  expect(Board.resolve(50) == 50, 'plain cell 50 stays put');

  // ------------------------------------------------------------- dice

  final Dice dice = Dice();
  bool inRange = true;
  for (int i = 0; i < 200; i++) {
    final int v = dice.roll();
    if (v < 1 || v > 6) {
      inRange = false;
    }
  }
  expect(inRange, 'dice always yields 1..6');

  // ------------------------------------------------------------- game rules

  final Game game = Game();
  expect(game.players.length == 2, 'two players are created');
  expect(game.currentPlayer.name.isNotEmpty, 'active player has a name');
  expect(!game.ended, 'game starts unfinished');

  // A turn passes play to the other player unless somebody wins.
  final TurnResult r1 = game.playTurn();
  expect(r1.roll >= 1 && r1.roll <= 6, 'turn returns a valid roll');
  expect(game.currentIndex != 0, 'turn alternates to the other player');

  // Exact-roll rule: overshooting cell 100 must not move the token.
  final Player actor = game.players[0];
  actor.position = 97;
  game.currentIndex = 0;
  // Force the dice to a known value by playing until an overshoot occurs.
  TurnResult overshootResult;
  int guard = 0;
  do {
    game.currentIndex = 0;
    // temporarily override the dice for determinism
    final mixer = game.dice;
    final saved = mixer.value;
    overshootResult = game.playTurn();
    guard++;
  } while (!overshootResult.overshoot && guard < 200);
  expect(guard < 200, 'overshoot case is reachable');
  if (overshootResult.overshoot) {
    expect(overshootResult.destination == 97, 'overshoot keeps token on 97');
  }

  // Winning: placing a token on 99 and rolling 1 wins.
  final Game endGame = Game();
  endGame.players[0].position = 99;
  endGame.currentIndex = 0;
  final TurnResult winTurn = endGame.playTurn();
  if (winTurn.roll == 1) {
    expect(winTurn.won, 'rolling 1 from 99 wins the game');
    expect(winTurn.destination == 100, 'winner lands exactly on 100');
    expect(endGame.ended, 'game is marked as ended');
    expect(endGame.winner == endGame.players[0], 'winner is recorded');
  }

  // ------------------------------------------------------------- report

  if (failures.isEmpty) {
    print('ALL $checks CHECKS PASSED');
  } else {
    print('$checks checks, ${failures.length} FAILURE(S):');
    for (final String f in failures) {
      print('  $f');
    }
  }
}
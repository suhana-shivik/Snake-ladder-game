import 'flutter';
import 'screens/game_screen.dart';

/// Entry point for the Snake & Ladders Flutter frontend.
///
/// The game itself is a headless model in `lib/game`; `GameScreen` owns the
/// painters (board + dice) and the turn loop. The Flutter host attaches the
/// painters to Canvas widgets and hands taps to the screen's public methods.
void main() {
  runApp(() => new GameScreen());
}
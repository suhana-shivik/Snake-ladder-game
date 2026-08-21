# Snake & Ladders — Flutter Frontend

A complete Flutter frontend for the classic 2-player Snake and Ladders board
game (see `docs/requirements/REQ-36.md`).

## Layout

```
frontend/
├── pubspec.yaml              # Dart package manifest
├── analysis_options.yaml
├── lib/
│   ├── main.dart             # app entry point
│   ├── game/                 # pure Dart game model (no UI dependency)
│   │   ├── board.dart        # 10x10 board, cells 1-100, snakes & ladders
│   │   ├── dice.dart         # six-sided dice
│   │   ├── player.dart       # token: name, colour, position
│   │   └── game.dart         # rules + turn controller
│   └── screens/
│       ├── board_painter.dart  # custom canvas painter: board/snakes/ladders/tokens
│       ├── dice_painter.dart   # pips dice (rolling face animation)
│       └── game_screen.dart    # screen controller: turn loop, status messages
├── web/
│   └── index.html            # web host page (light theme shell)
├── test/
│   └── game_test.dart        # dependency-free model checks
└── README.md
```

## Game rules implemented

- 10x10 board in boustrophedon layout (row 1 left→right, row 2 right→left, …).
- Cells 1–100 with alternating colours and corner numbers.
- Snakes (head→tail) and ladders (bottom→top) overlaid on the actual cells.
- Dice roll (`Dice`), rolling animation, then **cell-by-cell** token hops.
- Ladder / snake resolution after landing.
- Exact roll required for cell 100 — overshoot keeps the token in place and
  passes the turn.
- Two players (red & blue); both tokens visible side-by-side on the same cell.
- Turn indicator, winner banner / New Game.

## Run

Serve `web/` with a Dart web-capable server and run the Dart entrypoint
(`lib/main.dart`). From the project root:

```sh
cd frontend
dart run lib/main.dart
```

Or run the model checks:

```sh
cd frontend
dart run test/game_test.dart
```
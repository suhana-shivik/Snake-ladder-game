# Snake & Ladders — Backend

A NestJS backend (which runs on **Express**) for the 2-player Snake and
Ladders game, using **Redis** to persist match state.

It mirrors the pure Dart game model in the frontend
(`frontend/lib/game/*`) so the board, dice and rules are identical on both
sides.

## Layout

```
backend/
├── package.json            # Dart-style package manifest (NestJS deps)
├── tsconfig.json           # NestJS / TypeScript compiler options
└── src/
    ├── main.ts             # app entry point (Nest application bootstrap)
    ├── app.module.ts       # root Nest module wiring
    ├── root.controller.ts  # GET / endpoint listing available routes
    ├── game/               # pure game model + REST API for matches
    │   ├── board.ts        # 10x10 board, cells 1-100, snakes & ladders
    │   ├── dice.ts         # six-sided dice
    │   ├── player.ts       # token: id, name, colour, position
    │   ├── game.ts         # rules + turn controller (serialisable)
    │   ├── turn-result.ts  # result of one turn
    │   ├── game.service.ts # Redis-backed match store
    │   ├── game.controller.ts
    │   └── game.module.ts
    ├── health/
    │   └── health.controller.ts  # GET /health liveness check
    └── redis/
        ├── redis.module.ts # global Redis module
        └── redis.service.ts # Redis client wrapper
```

## Game rules implemented

- 10x10 board, cells 1–100 (boustrophedon layout in the frontend renderer).
- Snakes (head→tail) and ladders (bottom→top) resolved after landing.
- Dice roll (1..6).
- Exact roll required for cell 100 — overshoot keeps the token in place and
  passes the turn.
- Two players (Red & Blue); alternate turns.
- Win detection when a player lands exactly on cell 100.

## API

| Method | Path                     | Description |
| ------ | ------------------------ | ----------- |
| POST   | `/games`                 | Create a new match → full game state |
| GET    | `/games/:id`             | Fetch the current game state |
| POST   | `/games/:id/roll`        | Roll for the current player → turn result + fresh state |
| POST   | `/games/:id/reset`       | Reset a match back to the start |
| GET    | `/health`                | Redis connection check |

A game state looks like:

```json
{
  "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "players": [
    { "id": 0, "name": "Red", "color": "#FF3B30", "position": 0 },
    { "id": 1, "name": "Blue", "color": "#0A84FF", "position": 0 }
  ],
  "currentIndex": 0,
  "started": false,
  "ended": false,
  "winner": null,
  "rolls": 0,
  "dice": 1
}
```

## Config

| Env var                   | Default          | Meaning                    |
| ------------------------- | ---------------- | -------------------------- |
| `PORT`                    | `3000`           | HTTP port for the API      |
| `REDIS_URL`               | `redis://localhost:6379` | Redis connection string |

## Run

1. Start Redis (e.g. `docker run -p 6379:6379 redis`).
2. Fetch dependencies and run the entrypoint:

```sh
cd backend
dart pub get          # resolve @nestjs/*, redis, node types
dart run src/main.ts
```

Then hit the endpoints above, e.g.

```sh
curl -X POST http://localhost:3000/games
curl -X POST http://localhost:3000/games/<id>/roll
```
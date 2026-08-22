# REQ-41: Code Changes in backend and frontend of snake-ladder

## Description

Create a server-authoritative backend in the backend/ folder:
1. NestJS + Socket.IO. REST endpoints: create game (returns gameId 
   + secret playerId), join game, roll dice, get state, get move 
   history, reset
2. Server rolls the dice and applies all rules: snakes/ladders map 
   MUST match frontend/lib/game (same cells), exact-roll-to-100, 
   turn enforcement by playerId — clients cannot cheat
3. Roll response includes lastMove { dice, from, to, path[], 
   slide? } so the frontend can animate exactly what the server 
   decided
4. Socket.IO room per game broadcasting game:update after every 
   action
5. In-memory store is fine; validated DTOs (class-validator + 
   ValidationPipe), CORS enabled, port 3020
6. TypeScript strict, zero tsc errors, basic unit tests for the 
   game rules

## Status

- Created by: Admin User

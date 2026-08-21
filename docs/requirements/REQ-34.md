# REQ-34: Snake and Ladder game (animated)

## Description

Build a 2-player Snake and Ladder game as a single-page web app that 
looks and feels like the real board game.

BOARD:
- 10x10 grid, cells numbered 1-100 in boustrophedon layout (row 1 
  left-to-right, row 2 right-to-left, alternating — like the real board)
- Alternating cell colors, cell number in each cell's corner
- 5 snakes drawn as CURVED bodies (SVG bezier paths, distinct colors, 
  visible head at the top cell, tail at the bottom cell)
- 5 ladders drawn as two rails + rungs (SVG lines) connecting their 
  bottom and top cells at an angle
- Snakes and ladders overlay ON the board connecting their actual cells

DICE:
- 3D-looking dice showing pips (dots), not just a number
- On roll click: rolling animation (~0.5s changing faces / CSS shake) 
  before settling on the result

MOVEMENT (like the real game):
- Player token moves CELL BY CELL, hopping one square at a time 
  (~150ms per step) — never teleporting to the destination
- Landing on a ladder bottom: short pause, then token SLIDES UP along 
  the ladder path (smooth ~1s animation)
- Landing on a snake head: short pause, then token SLIDES DOWN 
  following the snake's curve (animate along the SVG path)
- Roll button disabled while any animation is running

GAME RULES:
- 2 players (red & blue tokens), alternate turns, active player 
  highlighted
- Both tokens visible side-by-side when on the same cell
- Exact roll needed to land on 100; overshoot = no move, turn passes
- Winner: celebration banner + New Game button

TECH:
- Single index.html — vanilla JS + CSS + inline SVG, no framework, 
  no build step
- Light theme, clean simple visuals

## Status

- Created by: Admin User

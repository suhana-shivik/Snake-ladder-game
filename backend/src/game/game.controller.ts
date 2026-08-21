import { Controller, Get, Param, Post } from '@nestjs/common';
import { GameState } from './game';
import { GameService } from './game.service';
import { TurnResult } from './turn-result';

/// REST endpoints for the Snake & Ladder game.
///
///   POST  /games            create a new match
///   GET   /games/:id        fetch the current state of a match
///   POST  /games/:id/roll   roll the dice for the current player
///   POST  /games/:id/reset  start the match over
@Controller('games')
export class GameController {
  constructor(private readonly games: GameService) {}

  @Post()
  async create(): Promise<GameState> {
    return this.games.create();
  }

  @Get(':id')
  async get(@Param('id') id: string): Promise<GameState> {
    return this.games.getGame(id);
  }

  @Post(':id/roll')
  async roll(
    @Param('id') id: string,
  ): Promise<TurnResult & { game: GameState }> {
    return this.games.roll(id);
  }

  @Post(':id/reset')
  async reset(@Param('id') id: string): Promise<GameState> {
    return this.games.reset(id);
  }
}
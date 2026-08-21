import { Controller, Get, Param, Post } from '@nestjs/common';
import { requireValidGameId } from './game.dto';
import { GameState } from './game';
import { GameService } from './game.service';
import { TurnResult } from './turn-result';

/// REST endpoints for the Snake & Ladder game.
///
///   POST  /games            create a new match
///   GET   /games/:id        fetch the current state of a match
///   POST  /games/:id/roll   roll the dice for the current player
///   POST  /games/:id/reset  start the match over
///
/// Every `:id` path segment is validated by [requireValidGameId] before it is
/// handed to the storage layer.
@Controller('games')
export class GameController {
  constructor(private readonly games: GameService) {}

  @Post()
  async create(): Promise<GameState> {
    return this.games.create();
  }

  @Get(':id')
  async get(@Param('id') id: string): Promise<GameState> {
    return this.games.getGame(requireValidGameId(id));
  }

  @Post(':id/roll')
  async roll(
    @Param('id') id: string,
  ): Promise<TurnResult & { game: GameState }> {
    return this.games.roll(requireValidGameId(id));
  }

  @Post(':id/reset')
  async reset(@Param('id') id: string): Promise<GameState> {
    return this.games.reset(requireValidGameId(id));
  }
}
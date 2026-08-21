import { Injectable, NotFoundException } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import { Game, GameState } from './game';
import { TurnResult } from './turn-result';

/// Orchestrates snake-ladder matches persisted in Redis.
@Injectable()
export class GameService {
  constructor(private readonly redis: RedisService) {}

  private key(id: string): string {
    return `snake-ladder:game:${id}`;
  }

  /// Creates a new game and persists it, returning its initial state.
  async create(): Promise<GameState> {
    const game = new Game();
    await this.save(game);
    return game.toJSON();
  }

  async getGame(id: string): Promise<GameState> {
    const game = await this.load(id);
    return game.toJSON();
  }

  /// Rolls the dice for the current player, applies the rules, persists the
  /// updated state and returns the turn result plus the fresh state.
  async roll(id: string): Promise<TurnResult & { game: GameState }> {
    const game = await this.load(id);
    const result = game.playTurn();
    await this.save(game);
    return { ...result, game: game.toJSON() };
  }

  async reset(id: string): Promise<GameState> {
    const game = await this.load(id);
    game.reset();
    await this.save(game);
    return game.toJSON();
  }

  /// Simple health endpoint: confirms the shared Redis connection is up.
  async health(): Promise<{ redis: string }> {
    const redis = await this.redis.ping();
    return { redis };
  }

  private async load(id: string): Promise<Game> {
    const raw = await this.redis.get(this.key(id));
    if (!raw) {
      throw new NotFoundException(`Game '${id}' not found`);
    }
    return Game.fromJSON(JSON.parse(raw) as GameState);
  }

  private async save(game: Game): Promise<void> {
    // Keep an in-progress game around for a day.
    await this.redis.set(this.key(game.id), JSON.stringify(game.toJSON()), 86400);
  }
}
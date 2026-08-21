import { Controller, Get } from '@nestjs/common';
import { GameService } from '../game/game.service';

/// Lightweight liveness check for the running service.
@Controller('health')
export class HealthController {
  constructor(private readonly games: GameService) {}

  @Get()
  async health(): Promise<{ status: string; redis: string }> {
    const { redis } = await this.games.health();
    return { status: 'ok', redis };
  }
}
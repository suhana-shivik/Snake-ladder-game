import { Module } from '@nestjs/common';
import { GameModule } from './game/game.module';
import { HealthController } from './health/health.controller';
import { RedisModule } from './redis/redis.module';
import { RootController } from './root.controller';

@Module({
  imports: [RedisModule, GameModule],
  controllers: [RootController, HealthController],
})
export class AppModule {}
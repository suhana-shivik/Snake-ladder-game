import { Global, Module } from '@nestjs/common';
import { RedisService } from './redis.service';

/// Global module exposing a single shared Redis client.
@Global()
@Module({
  providers: [RedisService],
  exports: [RedisService],
})
export class RedisModule {}
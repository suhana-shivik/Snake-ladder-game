import { Controller, Get } from '@nestjs/common';

/// Simple root endpoint so callers can confirm the API is reachable.
@Controller('/')
export class RootController {
  @Get()
  root(): { name: string; endpoints: string[] } {
    return {
      name: 'Snake & Ladder Backend',
      endpoints: [
        'POST /games',
        'GET /games/:id',
        'POST /games/:id/roll',
        'POST /games/:id/reset',
        'GET /health',
      ],
    };
  }
}
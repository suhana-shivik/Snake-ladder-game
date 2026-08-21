import { BadRequestException } from '@nestjs/common';

/// Request DTOs and validation helpers for the Snake & Ladder game API.
///
/// The API is deliberately read-mostly: a match is created with fixed Red/Blue
/// tokens and every move comes from a fair dice roll, so none of the request
/// DTOs carry mandatory body fields today. Their purpose is to (a) document
/// that each route does not expect a JSON body and (b) host the small amount
/// of input validation (the `:id` path segment) in one place so bad input is
/// rejected at the controller edge with a clear 4xx response instead of
/// reaching the Redis storage layer with an arbitrary key.

/// Matches the UUIDs `crypto.randomUUID()` issues for new games
/// (8-4-4-4-12 lower-case hex).
const GAME_ID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

/// Validates a `:id` route / path segment and returns it unchanged. Throws a
/// `BadRequestException` when the id is missing or malformed.
export function requireValidGameId(id: string): string {
  if (!GAME_ID_RE.test(id)) {
    throw new BadRequestException(`Malformed game id '${id}'`);
  }
  return id;
}

/// Request DTO for `POST /games`.
///
/// A fresh match always begins as Red vs Blue on the standard board, so no
/// client-supplied fields are required. Kept as a class so future optional
/// fields (custom player names, a board seed, …) slot in without churn.
export class CreateGameRequestDto {}

/// Request DTO for `POST /games/:id/roll`.
///
/// A roll is always drawn from the server-side dice, so the body is empty.
export class RollGameRequestDto {}
import { Injectable } from '@nestjs/common';
import { DriverLocationPayload } from '../domain/location-payload.js';

@Injectable()
export class RedisLocationStore {
  // In-memory representation of Redis hot state
  private readonly store: Map<string, DriverLocationPayload> = new Map();

  async saveLocation(rideId: string, payload: DriverLocationPayload): Promise<void> {
    const key = `ride:${rideId}:location`;
    this.store.set(key, payload);
    // In prod: await redis.setex(key, 60, JSON.stringify(payload)); // TTL of 60 seconds
  }

  async getLocation(rideId: string): Promise<DriverLocationPayload | null> {
    const key = `ride:${rideId}:location`;
    return this.store.get(key) || null;
  }
}

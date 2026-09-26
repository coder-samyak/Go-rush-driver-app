import { Injectable, Logger } from '@nestjs/common';
import { DriverLocationPayload } from '../domain/location-payload.js';
import { LocationSanityPolicy } from '../domain/location-sanity-policy.js';

@Injectable()
export class LocationIngestionService {
  private readonly logger = new Logger(LocationIngestionService.name);
  
  // In-memory mock of a Redis sequence tracker
  private sequenceTracker: Map<string, number> = new Map();

  constructor(private readonly sanityPolicy: LocationSanityPolicy) {}

  async processLocation(payload: DriverLocationPayload): Promise<boolean> {
    const sanity = this.sanityPolicy.evaluate(payload);
    if (!sanity.isValid) {
      this.logger.warn(`Rejected location for driver ${payload.driverId}: ${sanity.reason}`);
      return false;
    }

    const trackerKey = `ride:${payload.rideId}:driver:${payload.driverId}`;
    const lastSequence = this.sequenceTracker.get(trackerKey) || 0;

    // Out of order or duplicate check
    if (payload.sequenceNumber <= lastSequence) {
      this.logger.debug(`Ignored out-of-order/duplicate location seq ${payload.sequenceNumber} (latest is ${lastSequence})`);
      return false;
    }

    this.sequenceTracker.set(trackerKey, payload.sequenceNumber);
    return true; // Location is valid, fresh, and properly ordered.
  }
}

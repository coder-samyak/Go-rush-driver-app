import { Injectable } from '@nestjs/common';
import { DriverLocationPayload } from './location-payload.js';

export interface SanityResult {
  isValid: boolean;
  reason?: string;
}

@Injectable()
export class LocationSanityPolicy {
  private readonly MAX_ACCEPTABLE_ACCURACY_METERS = 50;

  evaluate(payload: DriverLocationPayload): SanityResult {
    if (payload.latitude < -90 || payload.latitude > 90) {
      return { isValid: false, reason: 'INVALID_LATITUDE' };
    }
    if (payload.longitude < -180 || payload.longitude > 180) {
      return { isValid: false, reason: 'INVALID_LONGITUDE' };
    }
    if (payload.accuracy < 0 || payload.accuracy > this.MAX_ACCEPTABLE_ACCURACY_METERS) {
      return { isValid: false, reason: 'POOR_GPS_ACCURACY' };
    }
    if (payload.speed !== undefined && payload.speed < 0) {
      return { isValid: false, reason: 'INVALID_SPEED' };
    }
    if (payload.heading !== undefined && (payload.heading < 0 || payload.heading > 360)) {
      return { isValid: false, reason: 'INVALID_HEADING' };
    }

    return { isValid: true };
  }
}

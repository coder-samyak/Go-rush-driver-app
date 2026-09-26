/**
 * Privacy-filtered DTO for family viewers.
 * Strips driverId, internal IDs, and excessive precision.
 */
export interface SharedRideLocation {
  latitude: number;
  longitude: number;
  updatedAt: Date;
}

export class SharedRideLocationMapper {
  static fromInternalPayload(payload: any): SharedRideLocation {
    return {
      latitude: payload.latitude,
      longitude: payload.longitude,
      updatedAt: payload.timestamp,
    };
  }
}

export interface DriverLocationPayload {
  driverId: string;
  rideId: string;
  latitude: number;
  longitude: number;
  accuracy: number;
  heading?: number;
  speed?: number;
  timestamp: Date;
  sequenceNumber: number;
}

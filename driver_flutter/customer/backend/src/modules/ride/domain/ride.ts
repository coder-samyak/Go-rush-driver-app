import { Quote } from '../../pricing/domain/quote.js';

export enum RideStatus {
  REQUESTED = 'REQUESTED',
  SEARCHING = 'SEARCHING',
  DRIVER_ASSIGNED = 'DRIVER_ASSIGNED',
  DRIVER_EN_ROUTE = 'DRIVER_EN_ROUTE',
  DRIVER_ARRIVED = 'DRIVER_ARRIVED',
  RIDE_STARTED = 'RIDE_STARTED',
  RIDE_IN_PROGRESS = 'RIDE_IN_PROGRESS',
  RIDE_COMPLETED = 'RIDE_COMPLETED',
  CANCELLED = 'CANCELLED',
  NO_DRIVER = 'NO_DRIVER',
  FAILED = 'FAILED',
}

export interface Ride {
  rideId: string;
  customerId: string;
  status: RideStatus;
  quoteSnapshot: Quote; // Authoritative pricing and routing snapshot at the time of booking
  pickupAddress?: string;
  dropoffAddress?: string;
  paymentMethod?: string;
  specialInstructions?: string;
  otpCode?: string;
  driverInfo?: {
    driverId: string;
    name: string;
    vehicle: string;
    plateNumber: string;
    rating: number;
    phone: string;
  };
  createdAt: Date;
  updatedAt: Date;
  cancellationReason?: string;
}

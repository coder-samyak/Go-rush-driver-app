import { RideCategoryType } from '../../pricing/domain/ride-category.js';

export enum DriverStatus {
  OFFLINE = 'OFFLINE',
  AVAILABLE = 'AVAILABLE',
  OFFERED = 'OFFERED',
  ON_TRIP = 'ON_TRIP',
  SUSPENDED = 'SUSPENDED',
}

export interface DriverLocation {
  lat: number;
  lng: number;
  updatedAt: Date;
}

export interface Driver {
  driverId: string;
  name: string;
  vehicleCategory: RideCategoryType;
  status: DriverStatus;
  currentLocation?: DriverLocation;
  serviceAreaId: string;
  isVerified: boolean;
}

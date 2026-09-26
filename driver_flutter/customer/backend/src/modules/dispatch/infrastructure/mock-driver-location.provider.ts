import { Injectable } from '@nestjs/common';
import { Driver, DriverStatus } from '../domain/driver.js';
import { RideCategoryType } from '../../pricing/domain/ride-category.js';

@Injectable()
export class MockDriverLocationProvider {
  private mockDrivers: Driver[] = [
    {
      driverId: 'drv_1',
      name: 'Ramesh K.',
      vehicleCategory: RideCategoryType.PRIME_SEDAN,
      status: DriverStatus.AVAILABLE,
      currentLocation: { lat: 22.7196, lng: 75.8577, updatedAt: new Date() },
      serviceAreaId: 'indore',
      isVerified: true,
    },
    {
      driverId: 'drv_2',
      name: 'Suresh M.',
      vehicleCategory: RideCategoryType.BIKE,
      status: DriverStatus.AVAILABLE,
      currentLocation: { lat: 22.7200, lng: 75.8580, updatedAt: new Date() },
      serviceAreaId: 'indore',
      isVerified: true,
    },
    {
      driverId: 'drv_3',
      name: 'Amit P.',
      vehicleCategory: RideCategoryType.AUTO,
      status: DriverStatus.ON_TRIP,
      currentLocation: { lat: 22.7210, lng: 75.8590, updatedAt: new Date() },
      serviceAreaId: 'indore',
      isVerified: true,
    }
  ];

  async findNearbyDrivers(lat: number, lng: number, radiusMeters: number): Promise<{driver: Driver, distanceMeters: number}[]> {
    // In production, this uses PostGIS ST_DWithin or Redis GEOSEARCH.
    // For this mock, we just return all drivers and mock distances.
    return this.mockDrivers.map((d, i) => ({
      driver: d,
      distanceMeters: (i + 1) * 500, // mock distance
    }));
  }

  async getDriver(driverId: string): Promise<Driver | null> {
    return this.mockDrivers.find(d => d.driverId === driverId) || null;
  }
}

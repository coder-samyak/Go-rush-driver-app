import { Injectable } from '@nestjs/common';
import { Driver, DriverStatus } from '../domain/driver.js';
import { RideCategoryType } from '../../pricing/domain/ride-category.js';

export interface EligibilityResult {
  isEligible: boolean;
  reason?: string;
}

@Injectable()
export class DriverEligibilityPolicy {
  private readonly MAX_LOCATION_AGE_SECONDS = 120;

  evaluate(driver: Driver, requiredCategory: RideCategoryType): EligibilityResult {
    if (!driver.isVerified) {
      return { isEligible: false, reason: 'VERIFICATION_INVALID' };
    }
    if (driver.status === DriverStatus.OFFLINE) {
      return { isEligible: false, reason: 'DRIVER_OFFLINE' };
    }
    if (driver.status === DriverStatus.SUSPENDED) {
      return { isEligible: false, reason: 'DRIVER_SUSPENDED' };
    }
    if (driver.status === DriverStatus.ON_TRIP) {
      return { isEligible: false, reason: 'DRIVER_BUSY' };
    }
    if (driver.status === DriverStatus.OFFERED) {
      return { isEligible: false, reason: 'ALREADY_OFFERED' };
    }
    if (driver.vehicleCategory !== requiredCategory) {
      return { isEligible: false, reason: 'CATEGORY_MISMATCH' };
    }
    if (!driver.currentLocation) {
      return { isEligible: false, reason: 'LOCATION_UNKNOWN' };
    }

    const ageInSeconds = (Date.now() - driver.currentLocation.updatedAt.getTime()) / 1000;
    if (ageInSeconds > this.MAX_LOCATION_AGE_SECONDS) {
      return { isEligible: false, reason: 'LOCATION_STALE' };
    }

    return { isEligible: true };
  }
}

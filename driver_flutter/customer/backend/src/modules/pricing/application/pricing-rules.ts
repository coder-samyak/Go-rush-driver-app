import { Money } from '../domain/money.js';
import { RideCategoryType } from '../domain/ride-category.js';

export interface PricingContext {
  category: RideCategoryType;
  distanceMeters: number;
  durationSeconds: number;
  cityId: string;
}

export interface PricingRule {
  evaluate(context: PricingContext): { type: string; label: string; amount: Money } | null;
}

export class BaseFareRule implements PricingRule {
  evaluate(context: PricingContext) {
    const baseFares: Record<RideCategoryType, number> = {
      [RideCategoryType.BIKE]: 2500,         // ₹25.00
      [RideCategoryType.BIKE_LITE]: 2000,    // ₹20.00
      [RideCategoryType.AUTO]: 3500,         // ₹35.00
      [RideCategoryType.AUTO_LITE]: 2800,    // ₹28.00
      [RideCategoryType.CAB]: 5000,          // ₹50.00
      [RideCategoryType.CAB_LITE]: 4200,     // ₹42.00
      [RideCategoryType.PRIME_SEDAN]: 7500,  // ₹75.00
      [RideCategoryType.SEVEN_SEATER]: 11000,// ₹110.00
    };
    return { type: 'BASE_FARE', label: 'Base Fare', amount: new Money(baseFares[context.category] ?? 3500) };
  }
}

export class DistanceFareRule implements PricingRule {
  evaluate(context: PricingContext) {
    const km = context.distanceMeters / 1000;
    const perKm: Record<RideCategoryType, number> = {
      [RideCategoryType.BIKE]: 900,          // ₹9.00/km
      [RideCategoryType.BIKE_LITE]: 750,     // ₹7.50/km
      [RideCategoryType.AUTO]: 1100,         // ₹11.00/km
      [RideCategoryType.AUTO_LITE]: 950,     // ₹9.50/km
      [RideCategoryType.CAB]: 1400,          // ₹14.00/km
      [RideCategoryType.CAB_LITE]: 1200,     // ₹12.00/km
      [RideCategoryType.PRIME_SEDAN]: 1800,  // ₹18.00/km
      [RideCategoryType.SEVEN_SEATER]: 2500, // ₹25.00/km
    };
    const rate = perKm[context.category] ?? 1200;
    const amount = Math.floor(km * rate);
    return { type: 'DISTANCE_FARE', label: 'Distance Fare', amount: new Money(amount) };
  }
}

export class BookingFeeRule implements PricingRule {
  evaluate(context: PricingContext) {
    return { type: 'BOOKING_FEE', label: 'Platform Fee', amount: new Money(1200) }; // ₹12.00
  }
}

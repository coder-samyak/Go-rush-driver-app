import { Money } from './money.js';
import { RideCategory } from './ride-category.js';

export interface FareComponent {
  type: string;
  label: string;
  amount: Money;
}

export interface FareBreakdown {
  subtotal: Money;
  components: FareComponent[];
  discount: Money;
  tax: Money;
  total: Money;
}

export interface Quote {
  quoteId: string;
  customerId: string;
  rideCategory: RideCategory;
  distanceMeters: number;
  durationSeconds: number;
  fareBreakdown: FareBreakdown;
  pricingVersion: string;
  createdAt: Date;
  expiresAt: Date;
  status: 'ACTIVE' | 'EXPIRED' | 'ACCEPTED' | 'CANCELLED';
}

import { Injectable } from '@nestjs/common';
import { PricingContext, PricingRule, BaseFareRule, DistanceFareRule, BookingFeeRule } from './pricing-rules.js';
import { FareBreakdown, FareComponent } from '../domain/quote.js';
import { Money } from '../domain/money.js';

@Injectable()
export class PricingEngine {
  private rules: PricingRule[] = [
    new BaseFareRule(),
    new DistanceFareRule(),
    new BookingFeeRule(),
  ];

  calculateFare(context: PricingContext): FareBreakdown {
    const components: FareComponent[] = [];
    let subtotalMinor = 0;

    for (const rule of this.rules) {
      const result = rule.evaluate(context);
      if (result) {
        components.push(result);
        subtotalMinor += result.amount.amountMinor;
      }
    }

    const subtotal = new Money(subtotalMinor, 'INR');
    
    // Stub Tax and Discount for this phase
    const discount = new Money(0, 'INR');
    
    // Tax 5%
    const taxMinor = Math.floor(subtotalMinor * 0.05);
    const tax = new Money(taxMinor, 'INR');

    const totalMinor = subtotalMinor - discount.amountMinor + taxMinor;
    const total = new Money(totalMinor, 'INR');

    return {
      subtotal,
      components,
      discount,
      tax,
      total,
    };
  }
}

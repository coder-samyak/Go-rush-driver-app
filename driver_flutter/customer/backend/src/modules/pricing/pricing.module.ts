import { Module } from '@nestjs/common';
import { PricingController } from './presentation/pricing.controller.js';
import { QuoteService } from './application/quote.service.js';
import { PricingEngine } from './application/pricing-engine.js';

@Module({
  controllers: [PricingController],
  providers: [QuoteService, PricingEngine],
  exports: [QuoteService],
})
export class PricingModule {}

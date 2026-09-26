import { Controller, Post, Get, Param, Body, Headers, UnauthorizedException } from '@nestjs/common';
import { QuoteService } from '../application/quote.service.js';

@Controller('v1/quotes')
export class PricingController {
  constructor(private readonly quoteService: QuoteService) {}

  @Post()
  async createQuotes(
    @Headers('Authorization') authHeader: string,
    @Headers('Idempotency-Key') idempotencyKey: string,
    @Body('distanceMeters') distanceMeters: number,
    @Body('durationSeconds') durationSeconds: number,
  ) {
    // In real app, extract customerId from AuthGuard/Token
    const customerId = authHeader ? 'cust_123' : null;
    if (!customerId) throw new UnauthorizedException();

    return this.quoteService.generateQuotes(customerId, distanceMeters, durationSeconds, idempotencyKey);
  }

  @Get(':id')
  async getQuote(
    @Headers('Authorization') authHeader: string,
    @Param('id') id: string
  ) {
    const customerId = authHeader ? 'cust_123' : null;
    if (!customerId) throw new UnauthorizedException();
    
    return this.quoteService.getQuote(id, customerId);
  }

  @Post('apply-promo')
  async applyPromo(
    @Headers('Authorization') authHeader: string,
    @Body('quoteId') quoteId: string,
    @Body('promoCode') promoCode: string,
  ) {
    const customerId = authHeader ? 'cust_123' : null;
    if (!customerId) throw new UnauthorizedException();

    return this.quoteService.applyPromo(quoteId, promoCode, customerId);
  }
}

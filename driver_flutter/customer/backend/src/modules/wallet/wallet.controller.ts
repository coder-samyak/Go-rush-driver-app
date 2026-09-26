import { Controller, Get, Post, Delete, Body, Param, Headers, UnauthorizedException } from '@nestjs/common';
import { WalletService } from './wallet.service.js';

@Controller('v1/wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  private extractCustomer(authHeader: string): string {
    const customerId = authHeader ? 'cust_123' : null;
    if (!customerId) throw new UnauthorizedException();
    return customerId;
  }

  @Get()
  getSummary(@Headers('Authorization') authHeader: string) {
    this.extractCustomer(authHeader);
    return this.walletService.getWalletSummary();
  }

  @Post('add-money')
  addMoney(
    @Headers('Authorization') authHeader: string,
    @Body('amountMinor') amountMinor: number,
    @Body('paymentMethodId') paymentMethodId?: string,
  ) {
    this.extractCustomer(authHeader);
    return this.walletService.addMoney(amountMinor, paymentMethodId);
  }

  @Get('transactions')
  getTransactions(@Headers('Authorization') authHeader: string) {
    this.extractCustomer(authHeader);
    return this.walletService.getTransactions();
  }

  @Get('refunds')
  getRefunds(@Headers('Authorization') authHeader: string) {
    this.extractCustomer(authHeader);
    return this.walletService.getRefunds();
  }

  @Get('payment-methods')
  getPaymentMethods(@Headers('Authorization') authHeader: string) {
    this.extractCustomer(authHeader);
    return this.walletService.getPaymentMethods();
  }

  @Post('payment-methods')
  addPaymentMethod(
    @Headers('Authorization') authHeader: string,
    @Body('type') type: 'UPI' | 'CARD' | 'NET_BANKING' | 'WALLET',
    @Body('title') title: string,
    @Body('subtitle') subtitle: string,
  ) {
    this.extractCustomer(authHeader);
    return this.walletService.addPaymentMethod(type, title, subtitle);
  }

  @Post('payment-methods/:id/set-default')
  setDefaultPaymentMethod(
    @Headers('Authorization') authHeader: string,
    @Param('id') id: string,
  ) {
    this.extractCustomer(authHeader);
    return this.walletService.setDefaultPaymentMethod(id);
  }

  @Delete('payment-methods/:id')
  deletePaymentMethod(
    @Headers('Authorization') authHeader: string,
    @Param('id') id: string,
  ) {
    this.extractCustomer(authHeader);
    return this.walletService.deletePaymentMethod(id);
  }

  @Get('promo-credits')
  getPromoCredits(@Headers('Authorization') authHeader: string) {
    this.extractCustomer(authHeader);
    return this.walletService.getPromoCredits();
  }

  @Post('redeem-promo')
  redeemPromo(
    @Headers('Authorization') authHeader: string,
    @Body('code') code: string,
  ) {
    this.extractCustomer(authHeader);
    return this.walletService.redeemPromo(code);
  }
}

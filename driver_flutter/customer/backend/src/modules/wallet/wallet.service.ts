import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';

export interface WalletTransaction {
  id: string;
  title: string;
  subtitle: string;
  type: 'TOPUP' | 'RIDE_PAYMENT' | 'REFUND' | 'PROMO_CREDIT' | 'CASHBACK';
  amountMinor: number;
  isDebit: boolean;
  timestamp: string;
  referenceId?: string;
  status: 'COMPLETED' | 'PENDING' | 'FAILED';
}

export interface RefundStatus {
  refundId: string;
  rideId: string;
  amountMinor: number;
  reason: string;
  status: 'PROCESSED' | 'IN_BANK' | 'PENDING';
  initiatedAt: string;
  estimatedCompletionAt: string;
  bankReferenceNumber?: string;
}

export interface PaymentMethod {
  id: string;
  type: 'UPI' | 'CARD' | 'NET_BANKING' | 'WALLET';
  title: string;
  subtitle: string;
  icon: string;
  isDefault: boolean;
  details?: Record<string, any>;
}

export interface PromoCredit {
  code: string;
  title: string;
  description: string;
  discountPercentage?: number;
  flatAmountMinor?: number;
  expiresAt: string;
  isRedeemed: boolean;
}

@Injectable()
export class WalletService {
  private walletBalanceMinor = 45000; // ₹450.00
  private promoBalanceMinor = 15000; // ₹150.00

  private transactions: WalletTransaction[] = [
    {
      id: 'tx_9801',
      title: 'Added to GoRush Wallet',
      subtitle: 'Via Google Pay (UPI)',
      type: 'TOPUP',
      amountMinor: 50000,
      isDebit: false,
      timestamp: new Date(Date.now() - 3600 * 1000 * 4).toISOString(),
      referenceId: 'UPI-9812401924',
      status: 'COMPLETED',
    },
    {
      id: 'tx_9802',
      title: 'Ride #ride_abc123',
      subtitle: 'Dropoff at IGI Terminal 3',
      type: 'RIDE_PAYMENT',
      amountMinor: 18900,
      isDebit: true,
      timestamp: new Date(Date.now() - 3600 * 1000 * 12).toISOString(),
      referenceId: 'ride_abc123',
      status: 'COMPLETED',
    },
    {
      id: 'tx_9803',
      title: 'Refund for Cancellation',
      subtitle: 'Ride #ride_prev99',
      type: 'REFUND',
      amountMinor: 13900,
      isDebit: false,
      timestamp: new Date(Date.now() - 3600 * 1000 * 36).toISOString(),
      referenceId: 'ref_30192',
      status: 'COMPLETED',
    },
    {
      id: 'tx_9804',
      title: 'Welcome Bonus Credit',
      subtitle: 'Promo Code WELCOME100',
      type: 'PROMO_CREDIT',
      amountMinor: 10000,
      isDebit: false,
      timestamp: new Date(Date.now() - 3600 * 1000 * 72).toISOString(),
      referenceId: 'PROMO-WELCOME100',
      status: 'COMPLETED',
    },
  ];

  private refunds: RefundStatus[] = [
    {
      refundId: 'ref_30192',
      rideId: 'ride_prev99',
      amountMinor: 13900,
      reason: 'Driver unfulfilled trip / Cancellation',
      status: 'PROCESSED',
      initiatedAt: new Date(Date.now() - 3600 * 1000 * 38).toISOString(),
      estimatedCompletionAt: new Date(Date.now() - 3600 * 1000 * 36).toISOString(),
      bankReferenceNumber: 'HDFC-REF-8891029',
    },
    {
      refundId: 'ref_40821',
      rideId: 'ride_delay12',
      amountMinor: 5000,
      reason: 'Route delay compensation',
      status: 'IN_BANK',
      initiatedAt: new Date(Date.now() - 3600 * 1000 * 6).toISOString(),
      estimatedCompletionAt: new Date(Date.now() + 3600 * 1000 * 18).toISOString(),
      bankReferenceNumber: 'ICICI-REF-1928374',
    },
  ];

  private paymentMethods: PaymentMethod[] = [
    {
      id: 'pm_gpay',
      type: 'UPI',
      title: 'Google Pay',
      subtitle: 'user@okicici',
      icon: 'gpay',
      isDefault: true,
    },
    {
      id: 'pm_phonepe',
      type: 'UPI',
      title: 'PhonePe UPI',
      subtitle: '9876543210@ybl',
      icon: 'phonepe',
      isDefault: false,
    },
    {
      id: 'pm_card_hdfc',
      type: 'CARD',
      title: 'HDFC Bank Credit Card',
      subtitle: '•••• •••• •••• 4829 (Expires 08/28)',
      icon: 'credit_card',
      isDefault: false,
    },
    {
      id: 'pm_paytm',
      type: 'WALLET',
      title: 'Paytm Wallet',
      subtitle: '+91 98765 43210',
      icon: 'account_balance_wallet',
      isDefault: false,
    },
  ];

  private promoCredits: PromoCredit[] = [
    {
      code: 'GORUSH50',
      title: '50% OFF Next 3 Rides',
      description: 'Maximum discount ₹75 per ride',
      discountPercentage: 50,
      expiresAt: new Date(Date.now() + 3600 * 1000 * 24 * 15).toISOString(),
      isRedeemed: false,
    },
    {
      code: 'AIRPORT100',
      title: '₹100 Flat Cashback on Airport Trips',
      description: 'Applicable on GoSedan category',
      flatAmountMinor: 10000,
      expiresAt: new Date(Date.now() + 3600 * 1000 * 24 * 30).toISOString(),
      isRedeemed: false,
    },
  ];

  getWalletSummary() {
    return {
      walletBalanceMinor: this.walletBalanceMinor,
      currency: 'INR',
      formattedWalletBalance: `₹${(this.walletBalanceMinor / 100).toFixed(2)}`,
      promoBalanceMinor: this.promoBalanceMinor,
      formattedPromoBalance: `₹${(this.promoBalanceMinor / 100).toFixed(2)}`,
      totalAvailableMinor: this.walletBalanceMinor + this.promoBalanceMinor,
      formattedTotalAvailable: `₹${((this.walletBalanceMinor + this.promoBalanceMinor) / 100).toFixed(2)}`,
      defaultPaymentMethod: this.paymentMethods.find((p) => p.isDefault) || this.paymentMethods[0],
    };
  }

  addMoney(amountMinor: number, paymentMethodId?: string) {
    if (amountMinor <= 0) {
      throw new BadRequestException({ code: 'INVALID_AMOUNT', message: 'Amount must be greater than 0' });
    }

    this.walletBalanceMinor += amountMinor;

    const pm = this.paymentMethods.find((p) => p.id === paymentMethodId) || this.paymentMethods[0];
    const newTx: WalletTransaction = {
      id: `tx_${Date.now()}`,
      title: 'Added to GoRush Wallet',
      subtitle: `Via ${pm.title}`,
      type: 'TOPUP',
      amountMinor,
      isDebit: false,
      timestamp: new Date().toISOString(),
      referenceId: `REF-${Math.floor(100000000 + Math.random() * 900000000)}`,
      status: 'COMPLETED',
    };

    this.transactions.unshift(newTx);

    return {
      status: 'TOPUP_SUCCESSFUL',
      transaction: newTx,
      newWalletSummary: this.getWalletSummary(),
    };
  }

  getTransactions() {
    return this.transactions;
  }

  getRefunds() {
    return this.refunds;
  }

  getPaymentMethods() {
    return this.paymentMethods;
  }

  addPaymentMethod(type: 'UPI' | 'CARD' | 'NET_BANKING' | 'WALLET', title: string, subtitle: string) {
    const newPm: PaymentMethod = {
      id: `pm_${Date.now()}`,
      type,
      title,
      subtitle,
      icon: type === 'CARD' ? 'credit_card' : type === 'UPI' ? 'qr_code_2' : 'account_balance',
      isDefault: this.paymentMethods.length === 0,
    };
    this.paymentMethods.push(newPm);
    return newPm;
  }

  setDefaultPaymentMethod(id: string) {
    const pm = this.paymentMethods.find((p) => p.id === id);
    if (!pm) throw new NotFoundException('Payment method not found');

    for (const p of this.paymentMethods) {
      p.isDefault = p.id === id;
    }
    return this.paymentMethods;
  }

  deletePaymentMethod(id: string) {
    const idx = this.paymentMethods.findIndex((p) => p.id === id);
    if (idx === -1) throw new NotFoundException('Payment method not found');
    this.paymentMethods.splice(idx, 1);
    if (this.paymentMethods.length > 0 && !this.paymentMethods.some((p) => p.isDefault)) {
      this.paymentMethods[0].isDefault = true;
    }
    return { success: true, remaining: this.paymentMethods };
  }

  getPromoCredits() {
    return this.promoCredits;
  }

  redeemPromo(code: string) {
    const cleanCode = code.trim().toUpperCase();
    if (cleanCode === 'WELCOME100' || cleanCode === 'GORUSH50' || cleanCode === 'FREERIDE') {
      const creditAmountMinor = cleanCode === 'WELCOME100' ? 10000 : 5000;
      this.promoBalanceMinor += creditAmountMinor;

      const newTx: WalletTransaction = {
        id: `tx_promo_${Date.now()}`,
        title: `Redeemed Code: ${cleanCode}`,
        subtitle: 'Added to Promo Credits',
        type: 'PROMO_CREDIT',
        amountMinor: creditAmountMinor,
        isDebit: false,
        timestamp: new Date().toISOString(),
        referenceId: `PROMO-${cleanCode}`,
        status: 'COMPLETED',
      };
      this.transactions.unshift(newTx);

      return {
        status: 'PROMO_REDEEMED',
        code: cleanCode,
        addedCreditMinor: creditAmountMinor,
        newWalletSummary: this.getWalletSummary(),
      };
    } else {
      throw new BadRequestException({ code: 'INVALID_PROMO_CODE', message: 'Promo code is invalid or expired.' });
    }
  }
}

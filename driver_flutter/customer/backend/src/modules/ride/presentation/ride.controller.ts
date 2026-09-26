import { Controller, Post, Get, Param, Body, Headers, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { RideService } from '../application/ride.service.js';

@Controller('v1/rides')
export class RideController {
  constructor(private readonly rideService: RideService) {}

  private extractCustomer(authHeader: string): string {
    const customerId = authHeader ? 'cust_123' : null;
    if (!customerId) throw new UnauthorizedException();
    return customerId;
  }

  @Post()
  async createRide(
    @Headers('Authorization') authHeader: string,
    @Headers('Idempotency-Key') idempotencyKey: string,
    @Body('quoteId') quoteId: string,
    @Body('pickupAddress') pickupAddress?: string,
    @Body('dropoffAddress') dropoffAddress?: string,
    @Body('paymentMethod') paymentMethod?: string,
    @Body('specialInstructions') specialInstructions?: string,
  ) {
    if (!idempotencyKey) {
      throw new BadRequestException({ code: 'RIDE_MISSING_IDEMPOTENCY', message: 'Idempotency-Key header is required' });
    }
    const customerId = this.extractCustomer(authHeader);
    return this.rideService.createRide(
      customerId,
      quoteId,
      idempotencyKey,
      pickupAddress,
      dropoffAddress,
      paymentMethod,
      specialInstructions,
    );
  }

  @Get('active')
  async getActiveRide(@Headers('Authorization') authHeader: string) {
    const customerId = this.extractCustomer(authHeader);
    return this.rideService.getActiveRide(customerId);
  }

  @Get(':id')
  async getRide(
    @Headers('Authorization') authHeader: string,
    @Param('id') id: string
  ) {
    const customerId = this.extractCustomer(authHeader);
    return this.rideService.getRide(id, customerId);
  }

  @Post(':rideId/cancel')
  async cancelRide(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
    @Body('reason') reason: string,
  ) {
    const customerId = this.extractCustomer(authHeader);
    return this.rideService.cancelRide(rideId, customerId, reason);
  }

  @Get(':rideId/realtime-state')
  async getRealtimeState(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
  ) {
    const customerId = this.extractCustomer(authHeader);
    const ride = await this.rideService.getActiveRide(customerId);
    
    if (!ride || ride.rideId !== rideId) {
      throw new UnauthorizedException('Ride not found or not owned by user');
    }
    
    return {
      rideId: ride.rideId,
      status: ride.status,
      latestLocation: { latitude: 28.6280, longitude: 77.3780 }, 
    };
  }

  @Post(':rideId/call-masked')
  async callMasked(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      maskedNumber: '+91 11 4084 1234',
      provider: 'GoRush Private Relay',
      status: 'CONNECTING',
      expiresInSeconds: 1800,
    };
  }

  @Post(':rideId/chat')
  async sendMessage(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
    @Body('text') text: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      messageId: `msg_${Date.now()}`,
      rideId,
      sender: 'CUSTOMER',
      text: text || 'Hello driver',
      timestamp: new Date().toISOString(),
    };
  }

  @Post(':rideId/sos')
  async triggerSOS(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      status: 'SOS_ALERT_SENT',
      policeHelpline: '112',
      emergencyContactsNotified: 2,
      locationBroadcast: true,
      timestamp: new Date().toISOString(),
    };
  }

  @Post(':rideId/share-trip')
  async shareTrip(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      shareId: `share_${Date.now()}`,
      trackingUrl: `https://gorush.app/track/${rideId}`,
      expiresAt: new Date(Date.now() + 2 * 3600 * 1000).toISOString(),
    };
  }

  @Post(':rideId/rating')
  async submitRating(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
    @Body('rating') rating: number,
    @Body('feedbackTags') feedbackTags: string[],
    @Body('comment') comment: string,
    @Body('tipAmount') tipAmount: number = 0,
  ) {
    this.extractCustomer(authHeader);
    return {
      status: 'RATING_SUBMITTED',
      rideId,
      rating: rating || 5,
      feedbackTags: feedbackTags || [],
      comment: comment || '',
      tipAmount: tipAmount || 0,
      driverThanked: true,
      timestamp: new Date().toISOString(),
    };
  }

  @Post(':rideId/issue')
  async reportIssue(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
    @Body('issueCategory') issueCategory: string,
    @Body('description') description: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      ticketId: `ticket_${Date.now()}`,
      rideId,
      issueCategory: issueCategory || 'GENERAL',
      status: 'OPEN',
      expectedResponseHours: 2,
      createdAt: new Date().toISOString(),
    };
  }

  @Post(':rideId/lost-item')
  async reportLostItem(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
    @Body('itemCategory') itemCategory: string,
    @Body('description') description: string,
    @Body('preferredContact') preferredContact?: string,
  ) {
    this.extractCustomer(authHeader);
    return {
      caseId: `case_lost_${Date.now()}`,
      rideId,
      itemCategory: itemCategory || 'PERSONAL_ITEM',
      driverNotified: true,
      status: 'SEARCHING_DRIVER',
      createdAt: new Date().toISOString(),
    };
  }

  @Get(':rideId/receipt')
  async getReceipt(
    @Headers('Authorization') authHeader: string,
    @Param('rideId') rideId: string,
  ) {
    const customerId = this.extractCustomer(authHeader);
    const ride = await this.rideService.getRide(rideId, customerId);

    return {
      invoiceId: `INV-2026-${rideId.substring(0, 6).toUpperCase()}`,
      rideId,
      date: ride.createdAt,
      driverName: ride.driverInfo?.name || 'Ramesh Kumar',
      vehicle: ride.driverInfo?.vehicle || 'Maruti Suzuki Dzire',
      pickupAddress: ride.pickupAddress || 'Sector 63, Noida',
      dropoffAddress: ride.dropoffAddress || 'Terminal 3, IGI Airport',
      paymentMethod: ride.paymentMethod || 'Google Pay',
      breakdown: ride.quoteSnapshot.fareBreakdown,
      pdfDownloadUrl: `https://api.gorush.app/v1/receipts/${rideId}.pdf`,
    };
  }
}

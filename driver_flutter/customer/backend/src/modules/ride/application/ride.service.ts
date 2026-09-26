import { Injectable, BadRequestException, NotFoundException } from '@nestjs/common';
import { Ride, RideStatus } from '../domain/ride.js';
import { RideStateMachine } from '../domain/ride-state-machine.js';
import { QuoteService } from '../../pricing/application/quote.service.js';
import * as crypto from 'crypto';

@Injectable()
export class RideService {
  constructor(private readonly quoteService: QuoteService) {}

  // In-memory stores mimicking a Database & Redis
  private rides: Map<string, Ride> = new Map();
  private activeRidesByCustomer: Map<string, string> = new Map(); // customerId -> rideId
  private idempotencyStore: Map<string, Ride> = new Map();

  async createRide(
    customerId: string,
    quoteId: string,
    idempotencyKey: string,
    pickupAddress: string = 'Sector 63, Noida (GPS Fixed)',
    dropoffAddress: string = 'Terminal 3, IGI Airport, New Delhi',
    paymentMethod: string = 'Google Pay',
    specialInstructions: string = '',
  ): Promise<Ride> {
    if (this.idempotencyStore.has(idempotencyKey)) {
      return this.idempotencyStore.get(idempotencyKey)!;
    }

    // 1. Concurrency Check: One active ride per customer
    if (this.activeRidesByCustomer.has(customerId)) {
      throw new BadRequestException({ code: 'RIDE_ALREADY_ACTIVE', message: 'You already have an active ride.' });
    }

    // 2. Fetch and Validate Quote
    const quote = await this.quoteService.getQuote(quoteId, customerId);

    // 3. Expiry Check
    if (quote.expiresAt < new Date()) {
      throw new BadRequestException({ code: 'RIDE_QUOTE_EXPIRED', message: 'Your fare has expired. Please get a new quote.' });
    }
    
    // Check if Quote is already consumed
    if (quote.status !== 'ACTIVE') {
      throw new BadRequestException({ code: 'RIDE_QUOTE_INVALID', message: 'This quote is no longer valid.' });
    }

    // 4. Create Ride Snapshot (Transactional Boundary)
    quote.status = 'ACCEPTED';

    const newRide: Ride = {
      rideId: crypto.randomUUID(),
      customerId,
      status: RideStatus.REQUESTED,
      quoteSnapshot: quote,
      pickupAddress,
      dropoffAddress,
      paymentMethod,
      specialInstructions,
      otpCode: Math.floor(1000 + Math.random() * 9000).toString(),
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    // Store entities
    this.rides.set(newRide.rideId, newRide);
    this.activeRidesByCustomer.set(customerId, newRide.rideId);
    this.idempotencyStore.set(idempotencyKey, newRide);

    // 5. Emit Domain Event
    console.log(`[RideEventPublisher] Published RideCreated for rideId: ${newRide.rideId}`);

    // Automatically transition to SEARCHING
    await this.transitionState(newRide.rideId, customerId, RideStatus.SEARCHING);
    
    return this.rides.get(newRide.rideId)!;
  }

  async failDispatch(rideId: string, customerId: string): Promise<void> {
    await this.transitionState(rideId, customerId, RideStatus.NO_DRIVER);
  }

  async assignDriverToRide(rideId: string, driverId: string): Promise<void> {
    const ride = this.rides.get(rideId);
    if (!ride) throw new Error('Ride not found');
    if (ride.status !== RideStatus.SEARCHING) {
      throw new Error('Ride is no longer searching.');
    }
    
    ride.driverInfo = {
      driverId,
      name: 'Ramesh Kumar',
      vehicle: 'Maruti Suzuki Dzire',
      plateNumber: 'UP16 B 4829',
      rating: 4.9,
      phone: '+91 98765 43210',
    };

    await this.transitionState(rideId, ride.customerId, RideStatus.DRIVER_ASSIGNED);
  }

  async getActiveRide(customerId: string): Promise<Ride | null> {
    const activeRideId = this.activeRidesByCustomer.get(customerId);
    if (!activeRideId) return null;
    return this.rides.get(activeRideId) || null;
  }

  async getRide(rideId: string, customerId: string): Promise<Ride> {
    const ride = this.rides.get(rideId);
    if (!ride) {
      throw new NotFoundException({ code: 'RIDE_NOT_FOUND', message: 'Ride not found' });
    }
    if (ride.customerId !== customerId) {
      throw new BadRequestException({ code: 'RIDE_UNAUTHORIZED', message: 'Unauthorized access' });
    }
    return ride;
  }

  async cancelRide(rideId: string, customerId: string, reason: string): Promise<Ride> {
    const ride = await this.getRide(rideId, customerId);

    // Validate Transition
    RideStateMachine.validateTransition(ride.status, RideStatus.CANCELLED);

    // Update State
    ride.status = RideStatus.CANCELLED;
    ride.cancellationReason = reason;
    ride.updatedAt = new Date();

    // Release Active Lock
    this.activeRidesByCustomer.delete(customerId);

    console.log(`[RideEventPublisher] Published RideCancelled for rideId: ${ride.rideId}`);

    return ride;
  }

  // Internal transition helper
  private async transitionState(rideId: string, customerId: string, nextState: RideStatus): Promise<void> {
    const ride = await this.getRide(rideId, customerId);
    RideStateMachine.validateTransition(ride.status, nextState);
    ride.status = nextState;
    ride.updatedAt = new Date();
    
    if (RideStateMachine.isTerminal(nextState)) {
      this.activeRidesByCustomer.delete(customerId);
    }
  }
}

import { Injectable, Logger } from '@nestjs/common';
import { Ride, RideStatus } from '../../ride/domain/ride.js';
import { RideService } from '../../ride/application/ride.service.js';
import { DriverEligibilityPolicy } from './driver-eligibility.policy.js';
import { DriverRankingPolicy } from './driver-ranking.policy.js';
import { MockDriverLocationProvider } from '../infrastructure/mock-driver-location.provider.js';
import { DriverOffer, DriverOfferStatus } from '../domain/driver-offer.js';
import { DriverOfferStateMachine } from '../domain/driver-offer-state-machine.js';
import * as crypto from 'crypto';

@Injectable()
export class DispatchEngine {
  private readonly logger = new Logger(DispatchEngine.name);
  
  // In memory store for offers
  private offers: Map<string, DriverOffer> = new Map();

  constructor(
    private readonly rideService: RideService,
    private readonly eligibilityPolicy: DriverEligibilityPolicy,
    private readonly rankingPolicy: DriverRankingPolicy,
    private readonly locationProvider: MockDriverLocationProvider,
  ) {}

  /**
   * Called asynchronously when a Ride is created.
   * This simulates a worker pulling from a Queue (e.g. BullMQ).
   */
  async handleRideCreatedEvent(ride: Ride): Promise<void> {
    this.logger.log(`[DispatchWorker] Started dispatch for Ride ${ride.rideId}`);
    const dispatchId = crypto.randomUUID();

    try {
      // 1. Discover Candidates
      const candidates = await this.locationProvider.findNearbyDrivers(
        // In real app, we'd use ride.pickup.lat/lng, but we don't have them in our mock Ride yet.
        22.7196, 75.8577, 5000 
      );

      // 2. Filter Eligibility
      const eligible = candidates.filter((c: any) => {
        const result = this.eligibilityPolicy.evaluate(c.driver, ride.quoteSnapshot.rideCategory.code);
        return result.isEligible;
      });

      if (eligible.length === 0) {
        this.logger.warn(`[DispatchWorker] No eligible drivers found for Ride ${ride.rideId}.`);
        await this.rideService.failDispatch(ride.rideId, ride.customerId);
        return;
      }

      // 3. Rank
      const ranked = this.rankingPolicy.rank(eligible);
      
      // 4. Create Offer for the top candidate
      const topCandidate = ranked[0];
      const offerId = crypto.randomUUID();
      
      const offer: DriverOffer = {
        offerId,
        dispatchId,
        rideId: ride.rideId,
        driverId: topCandidate.driver.driverId,
        status: DriverOfferStatus.PENDING,
        createdAt: new Date(),
        expiresAt: new Date(Date.now() + 15000), // 15 sec timeout
      };

      this.offers.set(offerId, offer);
      this.logger.log(`[DispatchWorker] Offer ${offerId} created for Driver ${topCandidate.driver.driverId}`);
      
      // MOCK REALTIME: In a real system we'd send a push notification here.
      // We will also simulate a "Driver Accepts" after 3 seconds for Phase 7 demonstration.
      setTimeout(() => {
        this.acceptOffer(offerId, topCandidate.driver.driverId).catch(e => {
          this.logger.error(`Simulated accept failed: ${e.message}`);
        });
      }, 3000);

    } catch (error: any) {
      this.logger.error(`[DispatchWorker] Error: ${error.message}`);
    }
  }

  /**
   * Called by the Partner API when a driver accepts an offer.
   */
  async acceptOffer(offerId: string, driverId: string): Promise<void> {
    const offer = this.offers.get(offerId);
    if (!offer) throw new Error('Offer not found');
    if (offer.driverId !== driverId) throw new Error('Unauthorized offer acceptance');

    // 1. State Validation
    DriverOfferStateMachine.validateTransition(offer.status, DriverOfferStatus.ACCEPTED);
    if (offer.expiresAt < new Date()) {
      offer.status = DriverOfferStatus.EXPIRED;
      throw new Error('Offer expired');
    }

    // 2. Ride State Validation (Atomic)
    // The ride must still be SEARCHING. If the customer cancelled, this will fail.
    await this.rideService.assignDriverToRide(offer.rideId, driverId);

    // 3. Mark offer accepted
    offer.status = DriverOfferStatus.ACCEPTED;
    offer.respondedAt = new Date();
    
    this.logger.log(`[DispatchWorker] Offer ${offerId} ACCEPTED. Ride ${offer.rideId} is now DRIVER_ASSIGNED.`);
  }

  async rejectOffer(offerId: string, driverId: string): Promise<void> {
    const offer = this.offers.get(offerId);
    if (!offer) throw new Error('Offer not found');
    if (offer.driverId !== driverId) throw new Error('Unauthorized');

    DriverOfferStateMachine.validateTransition(offer.status, DriverOfferStatus.REJECTED);
    offer.status = DriverOfferStatus.REJECTED;
    offer.respondedAt = new Date();
    
    this.logger.log(`[DispatchWorker] Offer ${offerId} REJECTED.`);
    // A real system would now trigger the next candidate offer
  }
}

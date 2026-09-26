import { Injectable, Logger } from '@nestjs/common';
import { LocationIngestionService } from '../application/location-ingestion.service.js';
import { RedisLocationStore } from '../infrastructure/redis-location-store.js';
import { DriverLocationPayload } from '../domain/location-payload.js';

/**
 * Structural abstraction for a NestJS WebSocketGateway.
 * We are not importing @nestjs/websockets due to disk constraints.
 */
@Injectable()
export class RealtimeGateway {
  private readonly logger = new Logger(RealtimeGateway.name);
  private connectedClients: Map<string, string> = new Map(); // clientId -> rideId (subscriptions)

  constructor(
    private readonly ingestionService: LocationIngestionService,
    private readonly locationStore: RedisLocationStore,
  ) {}

  // Triggered by Partner App over WS
  async handleDriverLocationPublish(clientId: string, payload: DriverLocationPayload): Promise<void> {
    // 1. Authenticate & Authorize Driver
    // In prod, driverId is extracted from JWT attached to the WS connection.
    const isAuthorized = true; // Simulating successful auth
    if (!isAuthorized) {
      this.logger.warn(`Unauthorized location publish from client ${clientId}`);
      return;
    }

    // 2. Validate & Ingest
    const isValid = await this.ingestionService.processLocation(payload);
    if (!isValid) return;

    // 3. Save Hot State (Redis)
    await this.locationStore.saveLocation(payload.rideId, payload);

    // 4. Broadcast to Customer
    this.broadcastToRide(payload.rideId, 'location_updated', payload);
  }

  // Triggered by Customer App over WS
  async handleCustomerSubscribe(clientId: string, authHeader: string, rideId: string): Promise<void> {
    // 1. Authenticate Customer & Verify Ride Ownership
    const customerId = 'cust_123'; // Decoded from JWT
    
    // In prod, inject RideService and check: rideService.getRide(rideId).customerId === customerId
    const ownsRide = true;
    
    if (!ownsRide) {
      this.logger.error(`Customer ${customerId} attempted to subscribe to unauthorized ride ${rideId}`);
      return; // Disconnect socket
    }

    // 2. Register Subscription
    this.connectedClients.set(clientId, rideId);
    this.logger.log(`Customer ${customerId} subscribed to realtime updates for ride ${rideId}`);
  }

  private broadcastToRide(rideId: string, event: string, data: any): void {
    // In prod: this.server.to(`ride:${rideId}`).emit(event, data);
    this.logger.debug(`[WS Broadcast] ride:${rideId} -> ${event}`);
  }
}

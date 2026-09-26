import { Injectable, Logger } from '@nestjs/common';
import * as crypto from 'crypto';
import { RideShareSession, RideShareStatus, RideShareStateMachine } from '../domain/ride-share-session.js';
import { WhatsAppMessagingProvider, MockWhatsAppProvider } from './whatsapp-messaging-provider.js';

@Injectable()
export class ShareSessionService {
  private readonly logger = new Logger(ShareSessionService.name);
  
  // Mock DB
  private sessions: Map<string, RideShareSession> = new Map();

  constructor(
    private readonly whatsappProvider: MockWhatsAppProvider // Use mock for structural demo
  ) {}

  async createShareSession(
    customerId: string, 
    rideId: string, 
    recipientName: string, 
    recipientPhone: string
  ): Promise<{ shareId: string, success: boolean }> {
    // 1. Validate Active Ride (Mocked check)
    // 2. Enforce MAX_ACTIVE_FAMILY_SHARES_PER_RIDE (mocked check)
    
    // 3. Generate high entropy tracking token
    const token = crypto.randomBytes(32).toString('hex');
    const tokenHash = this.hashToken(token);

    // E.164 normalization logic would go here.
    const phoneHash = this.hashToken(recipientPhone); // Mask PII

    const session: RideShareSession = {
      id: `share_${crypto.randomUUID()}`,
      rideId,
      customerId,
      recipientName,
      recipientPhoneHash: phoneHash,
      status: RideShareStatus.PENDING,
      tokenHash,
      createdAt: new Date(),
      expiresAt: new Date(Date.now() + 1000 * 60 * 60 * 24), // 24 hours
      consentVersion: '1.0'
    };

    this.sessions.set(session.id, session);
    this.logger.log(`Share session ${session.id} created by Customer ${customerId}`);

    // 4. Send WhatsApp
    const trackingUrl = `https://track.gorush.com/live/${token}`;
    const delivered = await this.whatsappProvider.sendRideShareMessage(recipientPhone, trackingUrl, 'Rohit');

    if (delivered && RideShareStateMachine.canTransition(session.status, RideShareStatus.ACTIVE)) {
      session.status = RideShareStatus.ACTIVE;
    }

    return { shareId: session.id, success: delivered };
  }

  async validateTrackingToken(token: string): Promise<RideShareSession | null> {
    const hash = this.hashToken(token);
    // Find session by hash (in a real DB, query by tokenHash)
    let foundSession: RideShareSession | null = null;
    for (const session of this.sessions.values()) {
      if (session.tokenHash === hash) {
        foundSession = session;
        break;
      }
    }

    if (!foundSession) return null;

    if (foundSession.status !== RideShareStatus.ACTIVE) {
      return null;
    }

    if (foundSession.expiresAt < new Date()) {
      foundSession.status = RideShareStatus.EXPIRED;
      return null;
    }

    return foundSession;
  }

  async revokeShare(customerId: string, shareId: string): Promise<boolean> {
    const session = this.sessions.get(shareId);
    if (!session || session.customerId !== customerId) return false;

    if (RideShareStateMachine.canTransition(session.status, RideShareStatus.REVOKED)) {
      session.status = RideShareStatus.REVOKED;
      session.revokedAt = new Date();
      this.logger.log(`Share session ${shareId} revoked by customer.`);
      // Realtime subsystem would be notified to drop WS connections here.
      return true;
    }
    return false;
  }

  private hashToken(token: string): string {
    return crypto.createHash('sha256').update(token).digest('hex');
  }
}

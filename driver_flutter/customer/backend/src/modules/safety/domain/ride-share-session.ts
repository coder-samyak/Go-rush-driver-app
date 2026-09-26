export enum RideShareStatus {
  PENDING = 'PENDING',
  ACTIVE = 'ACTIVE',
  REVOKED = 'REVOKED',
  EXPIRED = 'EXPIRED',
  COMPLETED = 'COMPLETED',
}

export interface RideShareSession {
  id: string;
  rideId: string;
  customerId: string;
  recipientName: string;
  recipientPhoneHash: string; // Do not store raw phone number in memory unnecessarily
  status: RideShareStatus;
  tokenHash: string; // The SHA-256 hash of the tracking token
  createdAt: Date;
  expiresAt: Date;
  revokedAt?: Date;
  consentVersion: string;
}

export class RideShareStateMachine {
  static canTransition(current: RideShareStatus, next: RideShareStatus): boolean {
    const transitions: Record<RideShareStatus, RideShareStatus[]> = {
      [RideShareStatus.PENDING]: [RideShareStatus.ACTIVE, RideShareStatus.REVOKED, RideShareStatus.EXPIRED],
      [RideShareStatus.ACTIVE]: [RideShareStatus.REVOKED, RideShareStatus.EXPIRED, RideShareStatus.COMPLETED],
      [RideShareStatus.REVOKED]: [],
      [RideShareStatus.EXPIRED]: [],
      [RideShareStatus.COMPLETED]: [],
    };
    return transitions[current].includes(next);
  }
}

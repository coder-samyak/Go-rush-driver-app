export enum DriverOfferStatus {
  PENDING = 'PENDING',
  ACCEPTED = 'ACCEPTED',
  REJECTED = 'REJECTED',
  EXPIRED = 'EXPIRED',
  CANCELLED = 'CANCELLED',
}

export interface DriverOffer {
  offerId: string;
  dispatchId: string;
  rideId: string;
  driverId: string;
  status: DriverOfferStatus;
  createdAt: Date;
  expiresAt: Date;
  respondedAt?: Date;
}

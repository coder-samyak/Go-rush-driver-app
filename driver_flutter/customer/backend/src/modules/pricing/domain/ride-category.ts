export enum RideCategoryType {
  BIKE = 'BIKE',
  BIKE_LITE = 'BIKE_LITE',
  AUTO = 'AUTO',
  AUTO_LITE = 'AUTO_LITE',
  CAB = 'CAB',
  CAB_LITE = 'CAB_LITE',
  PRIME_SEDAN = 'PRIME_SEDAN',
  SEVEN_SEATER = 'SEVEN_SEATER',
}

export interface RideCategory {
  id: string;
  code: RideCategoryType;
  displayName: string;
  description: string;
  capacity: number;
  etaMinutes: number;
  luggageCapacity?: number;
}

export const CATEGORIES: Record<RideCategoryType, RideCategory> = {
  [RideCategoryType.BIKE]: {
    id: 'cat_bike',
    code: RideCategoryType.BIKE,
    displayName: 'Bike',
    description: 'Quickest single-rider bike trip',
    capacity: 1,
    etaMinutes: 2,
    luggageCapacity: 1,
  },
  [RideCategoryType.BIKE_LITE]: {
    id: 'cat_bike_lite',
    code: RideCategoryType.BIKE_LITE,
    displayName: 'Bike lite',
    description: 'Budget-friendly quick bike ride',
    capacity: 1,
    etaMinutes: 3,
    luggageCapacity: 1,
  },
  [RideCategoryType.AUTO]: {
    id: 'cat_auto',
    code: RideCategoryType.AUTO,
    displayName: 'Auto',
    description: 'Doorstep 3-seater auto rickshaw',
    capacity: 3,
    etaMinutes: 4,
    luggageCapacity: 2,
  },
  [RideCategoryType.AUTO_LITE]: {
    id: 'cat_auto_lite',
    code: RideCategoryType.AUTO_LITE,
    displayName: 'Auto lite',
    description: 'Economical pocket-friendly auto',
    capacity: 3,
    etaMinutes: 5,
    luggageCapacity: 2,
  },
  [RideCategoryType.CAB]: {
    id: 'cat_cab',
    code: RideCategoryType.CAB,
    displayName: 'Cab',
    description: 'Comfortable hatchback AC cab',
    capacity: 4,
    etaMinutes: 3,
    luggageCapacity: 2,
  },
  [RideCategoryType.CAB_LITE]: {
    id: 'cat_cab_lite',
    code: RideCategoryType.CAB_LITE,
    displayName: 'Cab lite',
    description: 'Low fare everyday hatchback ride',
    capacity: 4,
    etaMinutes: 4,
    luggageCapacity: 2,
  },
  [RideCategoryType.PRIME_SEDAN]: {
    id: 'cat_prime_sedan',
    code: RideCategoryType.PRIME_SEDAN,
    displayName: 'Prime sedan',
    description: 'Top-rated spacious sedan (Dzire, Etios)',
    capacity: 4,
    etaMinutes: 3,
    luggageCapacity: 3,
  },
  [RideCategoryType.SEVEN_SEATER]: {
    id: 'cat_7_seater',
    code: RideCategoryType.SEVEN_SEATER,
    displayName: '7 seter',
    description: 'Spacious 7-seater SUV (Ertiga, Innova)',
    capacity: 7,
    etaMinutes: 5,
    luggageCapacity: 5,
  },
};

import { Injectable } from '@nestjs/common';

export interface TravelDeal {
  id: string;
  category: 'hotel' | 'flight' | 'bus' | 'train';
  title: string;
  subtitle: string;
  discountLabel: string;
  discountDescription: string;
  partner: string;
  deepLinkUrl: string;
  iconType: string;
  isZeroFee: boolean;
}

export interface TravelBanner {
  id: string;
  title: string;
  subtitle: string;
  promoCode: string;
  promoDescription: string;
  imageUrl: string;
  bgColor: string;
}

export interface HotelListing {
  id: string;
  name: string;
  location: string;
  rating: number;
  reviewCount: number;
  pricePerNight: number;
  originalPrice: number;
  discountPercent: number;
  thumbnailUrl: string;
  amenities: string[];
  partner: string;
}

export interface BusOption {
  id: string;
  operator: string;
  from: string;
  to: string;
  departureTime: string;
  arrivalTime: string;
  duration: string;
  busType: string;
  fare: number;
  originalFare: number;
  seatsAvailable: number;
  partner: string;
}

export interface FlightOption {
  id: string;
  airline: string;
  flightNumber: string;
  from: string;
  to: string;
  departureTime: string;
  arrivalTime: string;
  duration: string;
  fare: number;
  originalFare: number;
  classType: string;
  partner: string;
}

export interface TrainOption {
  id: string;
  trainName: string;
  trainNumber: string;
  from: string;
  to: string;
  departureTime: string;
  arrivalTime: string;
  duration: string;
  fare: number;
  classType: string;
  seatsAvailable: number;
  serviceFee: number;
  partner: string;
}

@Injectable()
export class TravelService {
  getBanner(): TravelBanner {
    return {
      id: 'banner_summer_2026',
      title: 'Summer Deals',
      subtitle: 'ONBOARD',
      promoCode: 'GORUSHTRAVEL',
      promoDescription: 'Use code at checkout',
      imageUrl: '/assets/gorush_travel_banner.jpg',
      bgColor: '#1565C0',
    };
  }

  getDeals(): TravelDeal[] {
    return [
      {
        id: 'deal_hotel_001',
        category: 'hotel',
        title: 'Hotel',
        subtitle: 'Best room rates',
        discountLabel: 'Upto 55% Off',
        discountDescription: 'On top hotel chains across India',
        partner: 'Goibibo',
        deepLinkUrl: 'https://goibibo.com',
        iconType: 'hotel',
        isZeroFee: false,
      },
      {
        id: 'deal_flight_001',
        category: 'flight',
        title: 'Flight',
        subtitle: 'Lowest fare, guaranteed',
        discountLabel: 'Upto ₹4000 Off',
        discountDescription: 'On domestic & international flights',
        partner: 'Goibibo',
        deepLinkUrl: 'https://goibibo.com/flights',
        iconType: 'flight',
        isZeroFee: false,
      },
      {
        id: 'deal_bus_001',
        category: 'bus',
        title: 'Bus',
        subtitle: 'Save big on',
        discountLabel: 'Upto 25% Off',
        discountDescription: 'On intercity bus bookings',
        partner: 'redBus',
        deepLinkUrl: 'https://redbus.in',
        iconType: 'bus',
        isZeroFee: false,
      },
      {
        id: 'deal_train_001',
        category: 'train',
        title: 'Train',
        subtitle: '',
        discountLabel: 'Zero Service Fee',
        discountDescription: 'Book trains with no extra charges',
        partner: 'Confirmtkt',
        deepLinkUrl: 'https://confirmtkt.com',
        iconType: 'train',
        isZeroFee: true,
      },
    ];
  }

  getHotels(): HotelListing[] {
    return [
      {
        id: 'hotel_001',
        name: 'The Leela Palace',
        location: 'New Delhi',
        rating: 4.8,
        reviewCount: 2340,
        pricePerNight: 4500,
        originalPrice: 9999,
        discountPercent: 55,
        thumbnailUrl: '',
        amenities: ['WiFi', 'Pool', 'Spa', 'Gym', 'Restaurant'],
        partner: 'Goibibo',
      },
      {
        id: 'hotel_002',
        name: 'Taj Mahal Hotel',
        location: 'Mumbai',
        rating: 4.9,
        reviewCount: 5200,
        pricePerNight: 6200,
        originalPrice: 12500,
        discountPercent: 50,
        thumbnailUrl: '',
        amenities: ['WiFi', 'Pool', 'Restaurant', 'Bar', 'Concierge'],
        partner: 'Goibibo',
      },
      {
        id: 'hotel_003',
        name: 'Ginger Hotel Noida',
        location: 'Noida, Sector 63',
        rating: 4.2,
        reviewCount: 890,
        pricePerNight: 1200,
        originalPrice: 2499,
        discountPercent: 52,
        thumbnailUrl: '',
        amenities: ['WiFi', 'Gym', 'Restaurant'],
        partner: 'Goibibo',
      },
    ];
  }

  getBuses(): BusOption[] {
    return [
      {
        id: 'bus_001',
        operator: 'VRL Travels',
        from: 'Delhi',
        to: 'Jaipur',
        departureTime: '22:00',
        arrivalTime: '05:30',
        duration: '7h 30m',
        busType: 'AC Sleeper',
        fare: 749,
        originalFare: 999,
        seatsAvailable: 12,
        partner: 'redBus',
      },
      {
        id: 'bus_002',
        operator: 'Orange Travels',
        from: 'Delhi',
        to: 'Agra',
        departureTime: '06:00',
        arrivalTime: '10:00',
        duration: '4h 00m',
        busType: 'AC Seater',
        fare: 350,
        originalFare: 450,
        seatsAvailable: 25,
        partner: 'redBus',
      },
    ];
  }

  getFlights(): FlightOption[] {
    return [
      {
        id: 'flight_001',
        airline: 'IndiGo',
        flightNumber: '6E-204',
        from: 'DEL',
        to: 'BOM',
        departureTime: '06:05',
        arrivalTime: '08:25',
        duration: '2h 20m',
        fare: 3499,
        originalFare: 5999,
        classType: 'Economy',
        partner: 'Goibibo',
      },
      {
        id: 'flight_002',
        airline: 'Air India',
        flightNumber: 'AI-805',
        from: 'DEL',
        to: 'BLR',
        departureTime: '09:30',
        arrivalTime: '12:15',
        duration: '2h 45m',
        fare: 4299,
        originalFare: 7500,
        classType: 'Economy',
        partner: 'Goibibo',
      },
    ];
  }

  getTrains(): TrainOption[] {
    return [
      {
        id: 'train_001',
        trainName: 'Rajdhani Express',
        trainNumber: '12301',
        from: 'NDLS',
        to: 'HWH',
        departureTime: '16:55',
        arrivalTime: '09:55+1',
        duration: '17h 00m',
        fare: 1350,
        classType: '3A',
        seatsAvailable: 34,
        serviceFee: 0,
        partner: 'Confirmtkt',
      },
      {
        id: 'train_002',
        trainName: 'Shatabdi Express',
        trainNumber: '12001',
        from: 'NDLS',
        to: 'BPL',
        departureTime: '06:00',
        arrivalTime: '13:55',
        duration: '7h 55m',
        fare: 855,
        classType: 'CC',
        seatsAvailable: 20,
        serviceFee: 0,
        partner: 'Confirmtkt',
      },
    ];
  }
}

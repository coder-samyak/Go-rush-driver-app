import { Injectable, BadRequestException } from '@nestjs/common';

export interface SavedPlace {
  id: string;
  type: 'home' | 'work' | 'favorite' | 'recent';
  title: string;
  subtitle: string;
  address: string;
  coordinate: { latitude: number; longitude: number };
}

export interface NearbyVehicle {
  id: string;
  category: 'GoBike' | 'GoAuto' | 'GoMini' | 'GoSedan';
  latitude: number;
  longitude: number;
  bearing: number;
  etaMinutes: number;
  driverName: string;
  rating: number;
}

@Injectable()
export class PlacesService {
  private mockSavedPlaces: SavedPlace[] = [
    {
      id: 'sp_home',
      type: 'home',
      title: 'Home',
      subtitle: 'G-Block, Sector 63, Noida',
      address: 'G-Block, Sector 63, Noida, UP 201301',
      coordinate: { latitude: 28.6280, longitude: 77.3780 },
    },
    {
      id: 'sp_work',
      type: 'work',
      title: 'Work',
      subtitle: 'Noida City Centre, Sector 32',
      address: 'Wave City Center, Sector 32, Noida',
      coordinate: { latitude: 28.5747, longitude: 77.3560 },
    },
    {
      id: 'sp_fav1',
      type: 'favorite',
      title: 'DLF Mall of India',
      subtitle: 'Sector 18, Noida',
      address: 'Plot M-03, Sector 18, Noida, UP',
      coordinate: { latitude: 28.5677, longitude: 77.3211 },
    },
    {
      id: 'sp_rec1',
      type: 'recent',
      title: 'Indira Gandhi International Airport (DEL)',
      subtitle: 'Terminal 3, New Delhi',
      address: 'New Delhi, Delhi 110037',
      coordinate: { latitude: 28.5562, longitude: 77.1000 },
    },
  ];

  async autocomplete(query: string) {
    if (!query) {
      throw new BadRequestException({ code: 'PLACE_MISSING_QUERY', message: 'Query is required' });
    }
    
    await new Promise((resolve) => setTimeout(resolve, 100));

    return [
      {
        placeId: 'place_1',
        description: `${query}, Sector 62, Noida, Uttar Pradesh`,
        mainText: query,
        secondaryText: 'Sector 62, Noida, Uttar Pradesh',
        coordinate: { latitude: 28.6270, longitude: 77.3720 },
      },
      {
        placeId: 'place_2',
        description: `${query} Metro Station, Line 3, Noida`,
        mainText: `${query} Metro Station`,
        secondaryText: 'Noida, Uttar Pradesh',
        coordinate: { latitude: 28.5740, longitude: 77.3550 },
      },
      {
        placeId: 'place_3',
        description: `${query} Tech Park, Electronic City, Sector 63`,
        mainText: `${query} Tech Park`,
        secondaryText: 'Sector 63, Noida, Uttar Pradesh',
        coordinate: { latitude: 28.6295, longitude: 77.3810 },
      },
    ];
  }

  async geocode(address: string) {
    if (!address) {
      throw new BadRequestException({ code: 'GEO_MISSING_ADDRESS', message: 'Address is required' });
    }
    
    await new Promise((resolve) => setTimeout(resolve, 100));
    return { latitude: 28.6280, longitude: 77.3780, address };
  }

  async reverseGeocode(lat: number, lng: number) {
    if (!lat || !lng) {
      throw new BadRequestException({ code: 'GEO_INVALID_COORDINATE', message: 'Coordinates are required' });
    }
    
    await new Promise((resolve) => setTimeout(resolve, 100));
    return { address: 'G-Block, Sector 63, Noida, Uttar Pradesh', latitude: lat, longitude: lng };
  }

  async placeDetails(placeId: string) {
    if (!placeId) {
      throw new BadRequestException({ code: 'PLACE_MISSING_ID', message: 'Place ID is required' });
    }

    await new Promise((resolve) => setTimeout(resolve, 100));
    return {
      placeId,
      name: 'Sector 63, Noida',
      formattedAddress: 'Sector 63, Noida, Uttar Pradesh 201301',
      coordinate: { latitude: 28.6280, longitude: 77.3780 },
    };
  }

  async getSavedPlaces() {
    return {
      home: this.mockSavedPlaces.find((p) => p.type === 'home'),
      work: this.mockSavedPlaces.find((p) => p.type === 'work'),
      favorites: this.mockSavedPlaces.filter((p) => p.type === 'favorite'),
      recents: this.mockSavedPlaces.filter((p) => p.type === 'recent'),
    };
  }

  async savePlace(place: Partial<SavedPlace>) {
    const newPlace: SavedPlace = {
      id: 'sp_' + Date.now(),
      type: place.type ?? 'favorite',
      title: place.title ?? 'Saved Location',
      subtitle: place.subtitle ?? 'Noida, UP',
      address: place.address ?? 'Noida, UP',
      coordinate: place.coordinate ?? { latitude: 28.6280, longitude: 77.3780 },
    };
    this.mockSavedPlaces.push(newPlace);
    return newPlace;
  }

  async getNearbyVehicles(lat: number = 28.6280, lng: number = 77.3780) {
    // Generate realistic nearby vehicle locations around specified coordinates
    return {
      vehicles: [
        {
          id: 'bike_1',
          category: 'GoBike',
          latitude: lat + 0.002,
          longitude: lng + 0.001,
          bearing: 45,
          etaMinutes: 2,
          driverName: 'Vikram Singh',
          rating: 4.9,
        },
        {
          id: 'auto_1',
          category: 'GoAuto',
          latitude: lat - 0.0015,
          longitude: lng + 0.0025,
          bearing: 120,
          etaMinutes: 4,
          driverName: 'Amit Kumar',
          rating: 4.8,
        },
        {
          id: 'mini_1',
          category: 'GoMini',
          latitude: lat + 0.003,
          longitude: lng - 0.002,
          bearing: 210,
          etaMinutes: 5,
          driverName: 'Suresh Sharma',
          rating: 4.7,
        },
        {
          id: 'sedan_1',
          category: 'GoSedan',
          latitude: lat - 0.001,
          longitude: lng - 0.0015,
          bearing: 310,
          etaMinutes: 3,
          driverName: 'Rahul Kumar',
          rating: 4.9,
        },
      ],
    };
  }
}

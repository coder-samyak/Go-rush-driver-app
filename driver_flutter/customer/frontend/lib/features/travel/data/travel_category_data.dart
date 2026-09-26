import 'package:flutter/material.dart';
import '../domain/models/travel_category_model.dart';

class TravelCategoryData {
  static const Map<String, TravelCategoryConfig> categories = {
    'beach': TravelCategoryConfig(
      id: 'beach',
      title: 'Beach Getaways',
      subtitle: 'Relax by the coast',
      destinations: [
        TravelDestination(
          id: 'goa',
          name: 'Goa',
          description: 'Sun, sand, and vibrant nightlife.',
          icon: Icons.beach_access_rounded,
          color: Colors.orangeAccent,
          estimatedTravelTime: '2h flight',
        ),
        TravelDestination(
          id: 'andaman',
          name: 'Andaman Islands',
          description: 'Pristine beaches and coral reefs.',
          icon: Icons.scuba_diving_rounded,
          color: Colors.lightBlue,
          estimatedTravelTime: '4h flight',
        ),
      ],
    ),
    'mountains': TravelCategoryConfig(
      id: 'mountains',
      title: 'Mountain Retreats',
      subtitle: 'Escape to the peaks',
      destinations: [
        TravelDestination(
          id: 'manali',
          name: 'Manali',
          description: 'Snow-capped peaks and adventure sports.',
          icon: Icons.downhill_skiing_rounded,
          color: Colors.blueGrey,
          estimatedTravelTime: '12h bus',
        ),
        TravelDestination(
          id: 'shimla',
          name: 'Shimla',
          description: 'Colonial charm in the Himalayas.',
          icon: Icons.landscape_rounded,
          color: Colors.green,
          estimatedTravelTime: '8h drive',
        ),
      ],
    ),
    'heritage': TravelCategoryConfig(
      id: 'heritage',
      title: 'Heritage Sites',
      subtitle: 'Explore rich history',
      destinations: [
        TravelDestination(
          id: 'jaipur',
          name: 'Jaipur',
          description: 'Palaces, forts, and vibrant culture.',
          icon: Icons.castle_rounded,
          color: Colors.redAccent,
          estimatedTravelTime: '5h drive',
        ),
        TravelDestination(
          id: 'hampi',
          name: 'Hampi',
          description: 'Ancient ruins of a glorious empire.',
          icon: Icons.account_balance_rounded,
          color: Colors.brown,
          estimatedTravelTime: 'Overnight train',
        ),
      ],
    ),
    'city': TravelCategoryConfig(
      id: 'city',
      title: 'City Breaks',
      subtitle: 'Experience urban energy',
      destinations: [
        TravelDestination(
          id: 'mumbai',
          name: 'Mumbai',
          description: 'The city that never sleeps.',
          icon: Icons.location_city_rounded,
          color: Colors.deepPurple,
          estimatedTravelTime: '2h flight',
        ),
        TravelDestination(
          id: 'bangalore',
          name: 'Bangalore',
          description: 'Silicon Valley with a vibrant pub culture.',
          icon: Icons.nightlife_rounded,
          color: Colors.indigo,
          estimatedTravelTime: '2.5h flight',
        ),
      ],
    ),
    'weekend': TravelCategoryConfig(
      id: 'weekend',
      title: 'Weekend Escapes',
      subtitle: 'Quick trips to recharge',
      destinations: [
        TravelDestination(
          id: 'lonavala',
          name: 'Lonavala',
          description: 'Lush green hills and waterfalls.',
          icon: Icons.nature_people_rounded,
          color: Colors.green,
          estimatedTravelTime: '2h drive',
        ),
        TravelDestination(
          id: 'coorg',
          name: 'Coorg',
          description: 'Coffee plantations and misty landscapes.',
          icon: Icons.local_cafe_rounded,
          color: Colors.brown,
          estimatedTravelTime: '5h drive',
        ),
      ],
    ),
  };
}

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'domain/places_models.dart';
import 'domain/location_models.dart';
abstract class PlacesProvider {
  Future<List<PlaceSuggestion>> autocomplete(String query);
  Future<PlaceDetails> getPlaceDetails(String placeId);
}

class PlacesProviderImpl implements PlacesProvider {
  // Using BehaviorSubject for debouncing query stream
  final _searchController = BehaviorSubject<String>();
  StreamSubscription? _searchSubscription;
  final void Function(List<PlaceSuggestion>) onResults;

  PlacesProviderImpl({required this.onResults}) {
    _searchSubscription = _searchController
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .listen((query) async {
          if (query.isEmpty) {
            onResults([]);
            return;
          }
          final results = await autocomplete(query);
          onResults(results);
        });
  }

  void search(String query) {
    _searchController.add(query);
  }

  void dispose() {
    _searchSubscription?.cancel();
    _searchController.close();
  }

  @override
  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    // Mock network call
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      PlaceSuggestion(
        placeId: 'mock_1',
        description: '$query, Bangalore',
        mainText: query,
        secondaryText: 'Bangalore, Karnataka',
      ),
      PlaceSuggestion(
        placeId: 'mock_2',
        description: '$query Road, Bangalore',
        mainText: '$query Road',
        secondaryText: 'Bangalore, Karnataka',
      ),
    ];
  }

  @override
  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const PlaceDetails(
      placeId: 'mock_1',
      name: 'Mock Place',
      formattedAddress: 'Mock Address, Bangalore, Karnataka',
      coordinate: GeoCoordinate(latitude: 12.9716, longitude: 77.5946),
    );
  }
}

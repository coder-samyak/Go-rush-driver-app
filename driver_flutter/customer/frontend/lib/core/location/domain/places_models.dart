import 'location_models.dart';

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  const PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });
}

class PlaceDetails {
  final String placeId;
  final String name;
  final String formattedAddress;
  final GeoCoordinate coordinate;

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.coordinate,
  });
}

class RouteSummary {
  final int distanceMeters;
  final int durationSeconds;
  final List<GeoCoordinate> polylinePoints;

  const RouteSummary({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polylinePoints,
  });
}

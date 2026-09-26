import 'domain/location_models.dart';
import 'domain/places_models.dart';

abstract class RoutingProvider {
  Future<RouteSummary> getRoute(GeoCoordinate origin, GeoCoordinate destination);
}

class MockRoutingProvider implements RoutingProvider {
  @override
  Future<RouteSummary> getRoute(GeoCoordinate origin, GeoCoordinate destination) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return RouteSummary(
      distanceMeters: 5500, // 5.5 km
      durationSeconds: 900, // 15 mins
      polylinePoints: [origin, destination], // Mock straight line
    );
  }
}

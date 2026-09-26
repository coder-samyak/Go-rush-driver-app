import 'domain/location_models.dart';

abstract class GeocodingProvider {
  Future<GeoCoordinate> geocode(String address);
  Future<String> reverseGeocode(GeoCoordinate coordinate);
}

class MockGeocodingProvider implements GeocodingProvider {
  @override
  Future<GeoCoordinate> geocode(String address) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return const GeoCoordinate(latitude: 12.9716, longitude: 77.5946);
  }

  @override
  Future<String> reverseGeocode(GeoCoordinate coordinate) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return '123 Main St, Bangalore';
  }
}

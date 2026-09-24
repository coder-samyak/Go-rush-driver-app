import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../core/theme.dart';
import '../models/ride_model.dart';
import '../services/location_service.dart';

/// Interactive OSM map used in the ride flow. It does not need a Google API key.
class LiveRideMap extends StatefulWidget {
  final RideModel ride;
  final bool showDestination;
  const LiveRideMap(
      {super.key, required this.ride, this.showDestination = true});

  @override
  State<LiveRideMap> createState() => _LiveRideMapState();
}

class _LiveRideMapState extends State<LiveRideMap> {
  final MapController _mapController = MapController();
  Position? _driverPosition;
  List<LatLng> _roadRoute = const [];

  @override
  void initState() {
    super.initState();
    _loadDriverLocation();
  }

  Future<void> _loadDriverLocation() async {
    final position = await LocationService.instance.currentPosition();
    if (!mounted || position == null) return;
    setState(() => _driverPosition = position);
    _mapController.move(LatLng(position.latitude, position.longitude), 14);
    _loadRoadRoute();
  }

  /// Fetches the driving geometry from OSRM. The visual design stays the same,
  /// but the blue line follows actual roads instead of connecting pins directly.
  Future<void> _loadRoadRoute() async {
    final driver = _driverPosition;
    if (driver == null) return;

    final pickup = LatLng(widget.ride.pickupLat, widget.ride.pickupLng);
    final destination = LatLng(widget.ride.destinationLat, widget.ride.destinationLng);
    final waypoints = [
      '${driver.longitude},${driver.latitude}',
      '${pickup.longitude},${pickup.latitude}',
      if (widget.showDestination) '${destination.longitude},${destination.latitude}',
    ].join(';');

    try {
      final response = await http
          .get(Uri.parse(
              'https://router.project-osrm.org/route/v1/driving/$waypoints?overview=full&geometries=geojson'))
          .timeout(const Duration(seconds: 12));
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = body['routes'] as List<dynamic>?;
      final firstRoute = routes != null && routes.isNotEmpty
          ? routes.first as Map<String, dynamic>
          : null;
      final geometry = firstRoute?['geometry'] as Map<String, dynamic>?;
      final coordinates = geometry?['coordinates'] as List<dynamic>?;
      if (!mounted || response.statusCode != 200 || coordinates == null) return;
      setState(() {
        _roadRoute = coordinates
            .whereType<List<dynamic>>()
            .where((point) => point.length >= 2)
            .map((point) => LatLng((point[1] as num).toDouble(), (point[0] as num).toDouble()))
            .toList(growable: false);
      });
    } catch (_) {
      // Tiles, markers, and the direct-line fallback remain available offline.
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickup = LatLng(widget.ride.pickupLat, widget.ride.pickupLng);
    final drop = LatLng(widget.ride.destinationLat, widget.ride.destinationLng);
    final driver = _driverPosition == null
        ? null
        : LatLng(_driverPosition!.latitude, _driverPosition!.longitude);
    final fallbackRoute = <LatLng>[
      if (driver != null) driver,
      pickup,
      if (widget.showDestination) drop
    ];
    final route = _roadRoute.isNotEmpty ? _roadRoute : fallbackRoute;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: driver ?? pickup, initialZoom: 13.5),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.gorush.driver',
          maxNativeZoom: 19,
        ),
        if (route.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                  points: route,
                  strokeWidth: 5,
                  color: QuickServeColors.routeBlue),
            ],
          ),
        MarkerLayer(
          markers: [
            if (driver != null)
              Marker(
                point: driver,
                width: 46,
                height: 46,
                child: _marker(
                    Icons.directions_car_rounded, QuickServeColors.primaryBlue),
              ),
            Marker(
              point: pickup,
              width: 42,
              height: 42,
              child: _marker(Icons.person_pin_circle_rounded,
                  QuickServeColors.statusGreen),
            ),
            if (widget.showDestination)
              Marker(
                point: drop,
                width: 42,
                height: 42,
                child: _marker(
                    Icons.location_on_rounded, QuickServeColors.statusRed),
              ),
          ],
        ),
      ],
    );
  }

  Widget _marker(IconData icon, Color color) => Container(
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3)),
        child: Icon(icon, color: Colors.white, size: 22),
      );
}

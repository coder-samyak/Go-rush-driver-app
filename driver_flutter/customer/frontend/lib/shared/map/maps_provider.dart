import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/location/domain/location_models.dart';

abstract class MapsProvider {
  Widget buildMap();
  void onMapCreated(dynamic controller);
  void moveCamera(GeoCoordinate coordinate, {double zoom = 14});
  void animateCamera(GeoCoordinate coordinate, {double zoom = 14});
  void setMarkers(List<GeoCoordinate> coordinates);
  void setRoutePolyline(List<GeoCoordinate> points);
  void clearMap();
  void dispose();
}

class OpenStreetMapProviderImpl implements MapsProvider {
  MapController? _controller;
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  final StreamController<void> _updateController = StreamController.broadcast();

  @override
  Widget buildMap() {
    return StreamBuilder<void>(
      stream: _updateController.stream,
      builder: (context, _) {
        return FlutterMap(
          mapController: _controller ?? MapController(),
          options: const MapOptions(
            initialCenter: LatLng(12.9716, 77.5946),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            PolylineLayer(
              polylines: _polylines,
            ),
            MarkerLayer(
              markers: _markers,
            ),
          ],
        );
      },
    );
  }

  @override
  void onMapCreated(dynamic controller) {
    if (controller is MapController) {
      _controller = controller;
    }
  }

  @override
  void moveCamera(GeoCoordinate coordinate, {double zoom = 14}) {
    _controller?.move(LatLng(coordinate.latitude, coordinate.longitude), zoom);
  }

  @override
  void animateCamera(GeoCoordinate coordinate, {double zoom = 14}) {
    _controller?.move(LatLng(coordinate.latitude, coordinate.longitude), zoom);
  }

  @override
  void setMarkers(List<GeoCoordinate> coordinates) {
    _markers = coordinates.asMap().entries.map((entry) {
      return Marker(
        point: LatLng(entry.value.latitude, entry.value.longitude),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      );
    }).toList();
    _updateController.add(null);
  }

  @override
  void setRoutePolyline(List<GeoCoordinate> points) {
    _polylines = [
      Polyline(
        points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: Colors.blue,
        strokeWidth: 4,
      )
    ];
    _updateController.add(null);
  }

  @override
  void clearMap() {
    _markers.clear();
    _polylines.clear();
    _updateController.add(null);
  }

  @override
  void dispose() {
    _updateController.close();
  }
}

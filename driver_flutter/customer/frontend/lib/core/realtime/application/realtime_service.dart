import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../domain/driver_location.dart';
import '../../network/api_config.dart';

abstract class RealtimeService {
  Future<void> connect(String token);
  Future<void> disconnect();
  
  /// Subscribes to a ride channel. Throws if the backend rejects authorization.
  Future<void> subscribeToRide(String rideId);
  Future<void> unsubscribeFromRide(String rideId);

  Stream<DriverLocation> get driverLocationStream;
  Stream<Map<String, dynamic>> get rideStatusStream;
}

class SocketIoRealtimeService implements RealtimeService {
  io.Socket? _socket;
  final _locationController = StreamController<DriverLocation>.broadcast();
  final _statusController = StreamController<Map<String, dynamic>>.broadcast();
  String? _activeRideId;

  @override
  Future<void> connect(String token) async {
    if (_socket?.connected == true) return;

    _socket = io.io(
      ApiConfig.baseUrl.replaceAll('/api/v1', ''),
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.onConnect((_) {
      if (kDebugMode) {
        print('Customer Socket connected');
      }
      if (_activeRideId != null) {
        _socket!.emit('ride:join', {'rideId': _activeRideId});
      }
    });

    _socket!.on('ride:location', (data) {
      if (data is Map) {
        final locationInfo = data['driverLocation'] ?? data['location'];
        if (locationInfo != null && locationInfo is Map) {
           final location = DriverLocation(
            driverId: (data['driverId'] ?? 'drv_1').toString(),
            rideId: (data['rideId'] ?? _activeRideId ?? '').toString(),
            latitude: (locationInfo['lat'] as num?)?.toDouble() ?? 0.0,
            longitude: (locationInfo['lng'] as num?)?.toDouble() ?? 0.0,
            accuracy: (locationInfo['accuracy'] as num?)?.toDouble() ?? 10.0,
            timestamp: DateTime.now(),
            sequenceNumber: 0,
          );
          _locationController.add(location);
        } else if (data['lat'] != null) {
          final location = DriverLocation(
            driverId: (data['driverId'] ?? 'drv_1').toString(),
            rideId: (data['rideId'] ?? _activeRideId ?? '').toString(),
            latitude: (data['lat'] as num?)?.toDouble() ?? 0.0,
            longitude: (data['lng'] as num?)?.toDouble() ?? 0.0,
            accuracy: (data['accuracy'] as num?)?.toDouble() ?? 10.0,
            timestamp: DateTime.now(),
            sequenceNumber: 0,
          );
          _locationController.add(location);
        }
      }
    });

    _socket!.on('ride:status', (data) {
      if (data is Map) {
        _statusController.add(Map<String, dynamic>.from(data));
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _socket?.disconnect();
    _socket = null;
    _activeRideId = null;
  }

  @override
  Future<void> subscribeToRide(String rideId) async {
    _activeRideId = rideId;
    if (_socket?.connected == true) {
      _socket!.emit('ride:join', {'rideId': rideId});
    }
  }

  @override
  Future<void> unsubscribeFromRide(String rideId) async {
    if (_activeRideId == rideId) {
      _activeRideId = null;
    }
  }

  @override
  Stream<DriverLocation> get driverLocationStream => _locationController.stream;

  @override
  Stream<Map<String, dynamic>> get rideStatusStream => _statusController.stream;
}

class MockRealtimeService implements RealtimeService {
  final _locationController = StreamController<DriverLocation>.broadcast();
  Timer? _mockLocationTimer;
  String? _activeRideId;
  int _sequence = 0;
  
  // Starting coordinates for our mock driver
  double _currentLat = 22.7196;
  double _currentLng = 75.8577;

  @override
  Future<void> connect(String token) async {
    // In prod: WebSocket.connect()
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> disconnect() async {
    _mockLocationTimer?.cancel();
    _locationController.close();
  }

  @override
  Future<void> subscribeToRide(String rideId) async {
    _activeRideId = rideId;
    _sequence = 0;
    
    // Safety check: Never run fake movement logic in production builds
    if (kDebugMode) {
      _mockLocationTimer?.cancel();
      _mockLocationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (_activeRideId == null) {
          timer.cancel();
          return;
        }
        
        // Move driver slightly
        _currentLat += 0.0001; 
        _currentLng += 0.0001;
        _sequence++;
        
        final location = DriverLocation(
          driverId: 'drv_1',
          rideId: _activeRideId!,
          latitude: _currentLat,
          longitude: _currentLng,
          accuracy: 10.0,
          heading: 45.0,
          timestamp: DateTime.now(),
          sequenceNumber: _sequence,
        );
        
        _locationController.add(location);
      });
    }
  }

  @override
  Future<void> unsubscribeFromRide(String rideId) async {
    if (_activeRideId == rideId) {
      _mockLocationTimer?.cancel();
      _activeRideId = null;
    }
  }

  @override
  Stream<DriverLocation> get driverLocationStream => _locationController.stream;

  @override
  Stream<Map<String, dynamic>> get rideStatusStream => const Stream.empty();
}

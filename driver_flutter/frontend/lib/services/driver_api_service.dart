import 'package:dio/dio.dart';
import '../models/models.dart';

class DriverApiService {
  static const String baseUrl = 'http://10.0.2.2:4000';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  Future<void> setOnlineStatus(String driverId, bool online) async {
    await _dio.patch('/v1/driver/status', data: {
      'driverId': driverId,
      'online': online,
    });
  }

  Future<List<DispatchOffer>> getOffers(String driverId) async {
    final res = await _dio.get('/v1/driver/offers', queryParameters: {'driverId': driverId});
    final List list = res.data;
    return list.map((item) => DispatchOffer.fromJson(item)).toList();
  }

  Future<void> acceptOffer(String offerId, String driverId) async {
    await _dio.post('/v1/driver/offers/$offerId/accept', data: {
      'driverId': driverId,
    });
  }

  Future<void> rejectOffer(String offerId, String driverId) async {
    await _dio.post('/v1/driver/offers/$offerId/reject', data: {
      'driverId': driverId,
    });
  }

  Future<void> markArrived(String rideId, String driverId) async {
    await _dio.post('/v1/rides/$rideId/arrived', data: {
      'driverId': driverId,
    });
  }

  Future<void> startTrip(String rideId, String driverId, String otp) async {
    await _dio.post('/v1/rides/$rideId/start', data: {
      'driverId': driverId,
      'otp': otp,
    });
  }

  Future<void> completeTrip(String rideId, String driverId) async {
    await _dio.post('/v1/rides/$rideId/complete', data: {
      'driverId': driverId,
    });
  }
}

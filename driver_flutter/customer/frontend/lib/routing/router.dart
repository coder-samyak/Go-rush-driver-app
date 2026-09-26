import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app/shell/app_shell.dart';
import '../features/onboarding/presentation/splash_screen.dart';
import '../features/onboarding/presentation/welcome_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/ride_history/presentation/activity_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/auth/presentation/phone_auth_screen.dart';
import '../features/auth/presentation/otp_verification_screen.dart';
import '../features/auth/presentation/profile_setup_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/registration_screen.dart';
import '../features/ride/presentation/ride_status_screen.dart';
import '../features/ride/presentation/post_ride_screen.dart';
import '../features/wallet/presentation/wallet_screen.dart';
import '../features/travel/presentation/travel_screen.dart';
import '../core/ride/data/ride_repository.dart';
import '../core/ride/domain/ride_models.dart';
import '../core/pricing/domain/quote_models.dart';
import '../core/pricing/domain/money.dart';
import '../core/pricing/domain/ride_category.dart';
import '../core/realtime/application/realtime_service.dart';
import '../core/wallet/data/wallet_repository.dart';
import '../core/security/token_manager.dart';
import '../core/security/secure_storage.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/auth/phone',
      builder: (context, state) => const PhoneAuthScreen(),
    ),
    GoRoute(
      path: '/auth/otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpVerificationScreen(phoneNumber: phone);
      },
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/auth/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/ride/status',
      builder: (context, state) {
        final ride = state.extra as Ride?;
        // Ensure realtime connection when entering ride status
        final realtimeService = SocketIoRealtimeService();
        TokenManager(SecureStorageImpl()).getAccessToken().then((token) {
          realtimeService.connect(token ?? 'mock_token');
        });
        
        return RideStatusScreen(
          initialRide: ride ?? Ride(
            rideId: 'ride_${DateTime.now().millisecondsSinceEpoch}',
            customerId: 'cust_123',
            status: RideStatus.driverAssigned,
            quoteSnapshot: Quote(
              quoteId: 'quote_1',
              rideCategory: const RideCategory(
                id: 'auto_lite',
                code: RideCategoryType.autoLite,
                displayName: 'Auto lite',
                description: 'Eco-friendly quick auto ride',
                capacity: 3,
                etaMinutes: 2,
              ),
              distanceMeters: 8500,
              durationSeconds: 1320,
              fareBreakdown: const FareBreakdown(
                subtotal: Money(amountMinor: 3500, currency: 'INR'),
                components: [],
                discount: Money(amountMinor: 0, currency: 'INR'),
                tax: Money(amountMinor: 0, currency: 'INR'),
                total: Money(amountMinor: 3500, currency: 'INR'),
              ),
              pricingVersion: 'v1.0',
              createdAt: DateTime.now(),
              expiresAt: DateTime.now().add(const Duration(minutes: 30)),
            ),
            pickupAddress: 'G-Block, Sector 63, Noida',
            dropoffAddress: 'Noida City Centre, Sector 32',
            paymentMethod: 'Google Pay',
            otpCode: '3487',
            driverName: 'Ramesh Kumar',
            driverPhone: '+91 98765 43210',
            driverVehicle: 'Bajaj RE Auto (EV)',
            driverPlate: 'UP16 B 4829',
            driverRating: 4.9,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          repository: HttpRideRepository(),
          realtimeService: realtimeService,
        );
      },
    ),
    GoRoute(
      path: '/post-ride',
      builder: (context, state) {
        final rideId = state.extra as String? ?? 'ride_abc123';
        return PostRideScreen(
          rideId: rideId,
          rideRepository: HttpRideRepository(),
          onComplete: () => context.go('/home'),
        );
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(),
        ),
        GoRoute(
          path: '/travel',
          builder: (context, state) => const TravelScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/wallet',
          builder: (context, state) => WalletScreen(walletRepository: HttpWalletRepository()),
        ),
      ],
    ),
  ],
);

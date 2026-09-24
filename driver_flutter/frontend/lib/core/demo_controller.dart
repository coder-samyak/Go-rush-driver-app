import 'dart:async';
import 'package:flutter/material.dart';

enum DemoScreen {
  splashScreen, // 01
  createAccount, // 02 (Create Account)
  loginRegister, // Alias for 02 backward compatibility
  profile, // 03 (Profile with emerald green wave)
  driverProfileVehicleSettings, // Alias for 03
  documentUpload, // 04 (Document upload)
  uploadDocuments, // Alias for 04
  otpVerification, // 05 (OTP Verification)
  homeDashboard, // 06 (Home / Dashboard)
  driverHomeDashboard, // Alias for 06
  rides, // 07 (Rides / My Rides)
  earnings, // 08 (Earnings)
  earningsInstantPayout, // Alias for 08
  incentives, // 09 (Incentives / Drive More Earn More)
  incentivesWeeklyQuests, // Alias for 09
  ratingsReviews, // 10 (Ratings & Reviews)
  ratingsReviewsDisputeCenter, // Alias for 10
  scheduledRides, // 11 (Scheduled Rides)
  scheduledRidesAdvanceBookings, // Alias for 11
  notifications, // 12 (Notifications)
  notificationCenterAlerts, // Alias for 12
  navigationLiveMap, // 13 (Navigation / Live Map / On Trip)
  activeTripNavigation, // Alias for 13
  tripCompletionReceipt, // 14 (Trip Completion / Receipt)
  tripCompletion, // Alias for 14
  instantCashOut, // 15 (Instant Cash Out)
  viewEarningStatement, // 16 (View Earning Statement)
  supportHub, // 17 (Support Hub)
  helpCenterSupportTickets, // Alias for 17
  settings, // 18 (Settings)
  login, // 19 (Login)
  forgotPassword, // 20 (Forgot Password)
  onboarding1, // 21 (Onboarding 1)
  onboarding2, // 22 (Onboarding 2)
  onboarding3, // 23 (Onboarding 3)
  fleetAdmin, // 24 (Admin / Fleet)
  adminPanelFleet, // Alias for 24
  // Extra aliases for complete safety
  driverProfileSetup,
  bankDetails,
  termsConditions,
  registrationComplete,
  incomingRideRequest,
  passengerTripManagement,
  fareBreakdown,
  tripHistoryDetailedReceipt,
  completedHistory,
  cancelledHistory,
  safetyHubSosCenter,
  vehicleManagement,
  supportTicketsScreen,
  aiChatbot,
  insurance,
  driverWallet, // Driver Wallet + Company Charge
}

class DemoStepInfo {
  final DemoScreen screen;
  final String title;
  final String codeName;
  final String subtitle;

  const DemoStepInfo({
    required this.screen,
    required this.title,
    required this.codeName,
    required this.subtitle,
  });
}

class DemoFlowController extends ChangeNotifier {
  static const int totalSeconds = 6;
  static const int tickIntervalMs = 100;
  static const int totalTicks = (totalSeconds * 1000) ~/ tickIntervalMs;

  static const List<DemoStepInfo> steps = [
    DemoStepInfo(
      screen: DemoScreen.splashScreen,
      title: '01 — Splash Screen',
      codeName: 'splash_screen',
      subtitle: 'GoRush Driver App • Blue Hatchback Night Car',
    ),
    DemoStepInfo(
      screen: DemoScreen.createAccount,
      title: '02 — Create Account',
      codeName: 'driver_login_registration',
      subtitle: 'Create Your Account • Join GoRush Today',
    ),
    DemoStepInfo(
      screen: DemoScreen.profile,
      title: '03 — Profile',
      codeName: 'driver_profile_vehicle_settings',
      subtitle: 'Rohit Sharma • 3.5 Rating • Go Online',
    ),
    DemoStepInfo(
      screen: DemoScreen.documentUpload,
      title: '04 — Document Upload',
      codeName: 'upload_documents_screen',
      subtitle: 'DL, RC, Insurance & Verification Status',
    ),
    DemoStepInfo(
      screen: DemoScreen.otpVerification,
      title: '05 — OTP Verification',
      codeName: 'otp_verification_liveness',
      subtitle: 'ID Card Graphic • 6-Digit OTP • Resend 00:59',
    ),
    DemoStepInfo(
      screen: DemoScreen.homeDashboard,
      title: '06 — Home / Dashboard',
      codeName: 'driver_home_dashboard',
      subtitle: 'Good Morning Pane Name • ₹12,400 Today • 5-Tab Nav',
    ),
    DemoStepInfo(
      screen: DemoScreen.rides,
      title: '07 — Rides',
      codeName: 'rides_screen',
      subtitle: 'My Rides • Ongoing & History • Accept / Decline',
    ),
    DemoStepInfo(
      screen: DemoScreen.earnings,
      title: '08 — Earnings',
      codeName: 'earnings_instant_payout',
      subtitle: 'Total Earnings ₹23,000 • Cash Out & Statement',
    ),
    DemoStepInfo(
      screen: DemoScreen.incentives,
      title: '09 — Incentives',
      codeName: 'incentives_weekly_quests',
      subtitle: 'Drive More Earn More • Challenges & Top Driver',
    ),
    DemoStepInfo(
      screen: DemoScreen.ratingsReviews,
      title: '10 — Ratings / Reviews',
      codeName: 'ratings_reviews_dispute_center',
      subtitle: '4.8 Score • 5-Star Breakdown & Driver Reviews',
    ),
    DemoStepInfo(
      screen: DemoScreen.scheduledRides,
      title: '11 — Scheduled Rides',
      codeName: 'scheduled_rides_advance_bookings',
      subtitle: 'Upcoming & Past • Airport, Office & Hotel Rides',
    ),
    DemoStepInfo(
      screen: DemoScreen.notifications,
      title: '12 — Notifications',
      codeName: 'notification_center_alerts',
      subtitle: 'Ride Request, Payout, Incentives & Alerts',
    ),
    DemoStepInfo(
      screen: DemoScreen.navigationLiveMap,
      title: '13 — Navigation / Live Map',
      codeName: 'active_trip_navigation',
      subtitle: 'On Trip • Live Route • Riya Sharma • End Trip',
    ),
    DemoStepInfo(
      screen: DemoScreen.tripCompletionReceipt,
      title: '14 — Trip Completion / Receipt',
      codeName: 'trip_completion_screen',
      subtitle: 'Ride Completed • ₹320 Total • View Receipt',
    ),
    DemoStepInfo(
      screen: DemoScreen.instantCashOut,
      title: '15 — Instant Cash Out',
      codeName: 'instant_cash_out_screen',
      subtitle: 'Available Balance ₹2,500 • Quick Withdraw',
    ),
    DemoStepInfo(
      screen: DemoScreen.viewEarningStatement,
      title: '16 — View Earning Statement',
      codeName: 'view_earning_statement_screen',
      subtitle: 'May 2026 • ₹23,000 • Vertical Bar Trend Chart',
    ),
    DemoStepInfo(
      screen: DemoScreen.supportHub,
      title: '17 — Support Hub',
      codeName: 'help_center_support_tickets',
      subtitle: 'Help Center • Live Chat • Call Support',
    ),
    DemoStepInfo(
      screen: DemoScreen.settings,
      title: '18 — Settings',
      codeName: 'settings_screen',
      subtitle: 'User Pane Driver • Documents • Vehicles • Log Out',
    ),
    DemoStepInfo(
      screen: DemoScreen.login,
      title: '19 — Login',
      codeName: 'driver_login_screen',
      subtitle: 'GoRush Driver App • Welcome Back! • Sign In',
    ),
    DemoStepInfo(
      screen: DemoScreen.forgotPassword,
      title: '20 — Forgot Password',
      codeName: 'forgot_password_screen',
      subtitle: 'Reset Password • Send OTP',
    ),
    DemoStepInfo(
      screen: DemoScreen.onboarding1,
      title: '21 — Onboarding 1',
      codeName: 'onboarding_slides_screen',
      subtitle: 'Drive Your Way • Flexible timings & control',
    ),
    DemoStepInfo(
      screen: DemoScreen.onboarding2,
      title: '22 — Onboarding 2',
      codeName: 'onboarding_slides_screen',
      subtitle: 'Get Ride Requests • Accept & navigate easily',
    ),
    DemoStepInfo(
      screen: DemoScreen.onboarding3,
      title: '23 — Onboarding 3',
      codeName: 'onboarding_slides_screen',
      subtitle: 'Earn More • Incentives, bonuses & cash out',
    ),
    DemoStepInfo(
      screen: DemoScreen.fleetAdmin,
      title: '24 — Admin / Fleet (Optional)',
      codeName: 'fleet_admin_screen',
      subtitle: 'Fleet Management • 124 Drivers • 110 Vehicles',
    ),
  ];

  DemoScreen _currentScreen;
  int _currentStepIndex;
  bool _isPlaying;
  int _currentTick = 0;
  Timer? _timer;

  DemoFlowController({
    DemoScreen initialScreen = DemoScreen.splashScreen,
    bool autoStart = false,
  })  : _currentScreen = initialScreen,
        _currentStepIndex = _indexForScreen(initialScreen),
        _isPlaying = autoStart {
    if (_isPlaying) {
      _startTimer();
    }
  }

  DemoScreen get currentScreen => _currentScreen;
  int get currentStepIndex => _currentStepIndex;
  int get currentIndex => _currentStepIndex;
  DemoStepInfo get currentStep => steps[_currentStepIndex];
  bool get isPlaying => _isPlaying;
  double get stepProgress => _currentTick / totalTicks;
  double get progress => stepProgress;
  String get currentScreenTitle => steps[_currentStepIndex].title;
  String get currentCodeName => steps[_currentStepIndex].codeName;
  String get currentSubtitle => steps[_currentStepIndex].subtitle;

  static int _indexForScreen(DemoScreen screen) {
    for (int i = 0; i < steps.length; i++) {
      if (steps[i].screen == screen) return i;
    }
    return 0;
  }

  void _startTimer() {
    _timer?.cancel();
    _currentTick = 0;
    _timer = Timer.periodic(const Duration(milliseconds: tickIntervalMs), (timer) {
      _currentTick++;
      if (_currentTick >= totalTicks) {
        _currentTick = 0;
        _advanceToNextScreen();
      }
      notifyListeners();
    });
  }

  void _advanceToNextScreen() {
    _currentStepIndex = (_currentStepIndex + 1) % steps.length;
    _currentScreen = steps[_currentStepIndex].screen;
    _currentTick = 0;
    notifyListeners();
  }

  void userInteracted({bool pauseAuto = true}) {
    if (pauseAuto && _isPlaying) {
      pause();
    }
  }

  void play() {
    if (!_isPlaying) {
      _isPlaying = true;
      _startTimer();
      notifyListeners();
    }
  }

  void pause() {
    if (_isPlaying) {
      _isPlaying = false;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void nextScreen() {
    _advanceToNextScreen();
  }

  void next() => nextScreen();

  void previousScreen() {
    _currentStepIndex = (_currentStepIndex - 1 + steps.length) % steps.length;
    _currentScreen = steps[_currentStepIndex].screen;
    _currentTick = 0;
    notifyListeners();
  }

  void previous() => previousScreen();

  void jumpToScreen(DemoScreen screen) {
    _currentScreen = screen;
    _currentStepIndex = _indexForScreen(screen);
    _currentTick = 0;
    notifyListeners();
  }

  void jumpTo(int index) => jumpToIndex(index);

  void jumpToIndex(int index) {
    if (index >= 0 && index < steps.length) {
      _currentStepIndex = index;
      _currentScreen = steps[index].screen;
      _currentTick = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/typography.dart';
import '../../../features/auth/domain/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    final repository = AuthRepositoryImpl();
    final sessionCheck = repository.checkSession();
    await Future.delayed(const Duration(milliseconds: 250));
    final hasSession = await sessionCheck;

    if (!mounted) return;
    context.go(hasSession ? '/home' : '/auth/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GoRushColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: GoRushColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.directions_car_rounded, size: 48, color: GoRushColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'GoRush',
              style: GoRushTypography.display.copyWith(
                color: GoRushColors.surface,
                fontWeight: FontWeight.bold,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fast & Reliable Rides',
              style: GoRushTypography.body.copyWith(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

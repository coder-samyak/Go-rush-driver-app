import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../services/token_storage_service.dart';

class RegistrationCompleteScreen extends StatelessWidget {
  final VoidCallback? onGoHome;

  const RegistrationCompleteScreen({
    super.key,
    this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Green Checkmark Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F8EE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: QuickServeColors.statusGreen,
                    size: 56,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Profile Submitted!',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              Text(
                'Thank you, ${TokenStorageService.instance.driverProfile?['name'] ?? 'Partner'}! Your partner application and vehicle documents are under automated review. You can now explore the driver app dashboard.',
                style: const TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // Verification status pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hourglass_top, color: Color(0xFF2563EB), size: 16),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Document Verification Status: 90% Complete',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: onGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Go to Home Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

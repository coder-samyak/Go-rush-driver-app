import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OtpVerificationLivenessScreen extends StatefulWidget {
  final VoidCallback? onVerifySuccess;
  final VoidCallback? onBackTap;

  const OtpVerificationLivenessScreen({
    super.key,
    this.onVerifySuccess,
    this.onBackTap,
  });

  @override
  State<OtpVerificationLivenessScreen> createState() => _OtpVerificationLivenessScreenState();
}

class _OtpVerificationLivenessScreenState extends State<OtpVerificationLivenessScreen> {
  // 6 digits matching reference Phone 5
  final List<String> _otpDigits = ['5', '8', '2', '4', '9', '1'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
          onPressed: widget.onBackTap ?? () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // ID Card graphic with green checkmark
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: QuickServeColors.primaryBlue.withOpacity(0.2), width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 48,
                        color: QuickServeColors.primaryBlue,
                      ),
                      Positioned(
                        right: 18,
                        bottom: 18,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: QuickServeColors.statusGreen,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title matching reference Phone 5
              const Center(
                child: Text(
                  'OTP Verification',
                  style: TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Enter the 6-digit code sent to your\nregistered mobile number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 6 Distinct Rounded OTP Digit Boxes matching reference Phone 5
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 46,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: QuickServeColors.primaryBlue.withOpacity(0.4),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _otpDigits[index],
                        style: const TextStyle(
                          color: QuickServeColors.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Resend in 00:59',
                      style: TextStyle(
                        color: QuickServeColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Royal Cobalt Blue Verify CTA Button
              ElevatedButton(
                onPressed: widget.onVerifySuccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: QuickServeColors.primaryBlue.withOpacity(0.35),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Security Badge
              const Center(
                child: Text(
                  'GoRush 100% Secure Verification • Encrypted',
                  style: TextStyle(
                    color: QuickServeColors.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/app_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onSendOtp;
  final VoidCallback? onLoginTap;

  const ForgotPasswordScreen({
    super.key,
    this.onBackTap,
    this.onSendOtp,
    this.onLoginTap,
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+91 81224 367641');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Lock graphic illustration (Phone 20)
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: QuickServeColors.primaryBlue.withOpacity(0.2), width: 2),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 48,
                    color: QuickServeColors.primaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Center(
                child: Text(
                  'Reset Your Password',
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
                  'Enter your registered mobile number to\nreceive a 6-digit OTP code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: QuickServeColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Phone Number Input
              const Text(
                'Phone Number',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: QuickServeColors.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: QuickServeColors.borderLight),
                ),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.phone_outlined, color: QuickServeColors.textSecondary, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Send OTP CTA Button
              ElevatedButton(
                onPressed: () {
                  AppToast.showSuccess(
                    context,
                    'OTP sent to registered mobile number.',
                  );
                  if (widget.onSendOtp != null) {
                    widget.onSendOtp!();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: QuickServeColors.primaryBlue.withOpacity(0.3),
                ),
                child: const Text(
                  'Send OTP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 28),

              // Back to Login Link
              Center(
                child: GestureDetector(
                  onTap: widget.onLoginTap ?? widget.onBackTap,
                  child: const Text(
                    'Back to Login',
                    style: TextStyle(
                      color: QuickServeColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

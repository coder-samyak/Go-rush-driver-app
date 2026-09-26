import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/widgets/buttons/gorush_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  bool _isLoading = false;
  String? _errorText;
  int _countdown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _countdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorText = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/auth/profile-setup');
      }
    });
  }

  void _onInputChanged(String value, int index) {
    setState(() => _errorText = null);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == 5) {
      _focusNodes[index].unfocus();
      _verifyOtp();
    }
  }

  void _resendOtp() {
    if (_countdown == 0) {
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent successfully'),
          backgroundColor: Color(0xFF00C853),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withValues(alpha: 0.15),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/phone_auth_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.85),
                          Colors.white.withValues(alpha: 0.60),
                          Colors.white.withValues(alpha: 0.95),
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(GoRushSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: GoRushColors.border),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: GoRushColors.textPrimary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GoRushSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C853).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: Color(0xFF00C853),
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: GoRushSpacing.lg),
                        Text(
                          'Verify your number',
                          style: GoRushTypography.display.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: GoRushColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: GoRushTypography.body.copyWith(
                              color: GoRushColors.textSecondary,
                              height: 1.45,
                            ),
                            children: [
                              const TextSpan(text: 'Enter the 6-digit code sent to '),
                              TextSpan(
                                text: '+91 ${widget.phoneNumber}',
                                style: const TextStyle(
                                  color: Color(0xFF00C853),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: GoRushSpacing.xxl),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => SizedBox(
                              width: 44,
                              height: 56,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                onChanged: (value) => _onInputChanged(value, index),
                                style: GoRushTypography.headline.copyWith(
                                  color: const Color(0xFF00C853),
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(GoRushRadius.md),
                                    borderSide: BorderSide(
                                      color: _errorText != null ? GoRushColors.error : GoRushColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(GoRushRadius.md),
                                    borderSide: BorderSide(
                                      color: _controllers[index].text.isNotEmpty
                                          ? const Color(0xFF00C853)
                                          : GoRushColors.border,
                                      width: _controllers[index].text.isNotEmpty ? 1.5 : 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(GoRushRadius.md),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF00C853),
                                      width: 2.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: GoRushSpacing.sm),
                          Text(
                            _errorText!,
                            style: GoRushTypography.caption.copyWith(color: GoRushColors.error),
                          ),
                        ],
                        const SizedBox(height: GoRushSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Didn't receive code? ", style: GoRushTypography.body),
                            GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                _countdown > 0 ? 'Retry in 00:$_countdown' : 'Resend Code',
                                style: GoRushTypography.body.copyWith(
                                  color: _countdown > 0 ? GoRushColors.textMuted : const Color(0xFF00C853),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: GoRushButton(
                            label: 'Verify & Proceed',
                            isLoading: _isLoading,
                            onPressed: _verifyOtp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }
}

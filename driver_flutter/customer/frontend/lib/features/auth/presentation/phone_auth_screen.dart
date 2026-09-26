import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/widgets/buttons/gorush_button.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorText;
  int _selectedAuthTab = 0; // 0: Mobile OTP, 1: Email Login, 2: Social Login
  bool _whatsappConsent = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  void _validateAndSubmit() {
    setState(() {
      _errorText = null;
    });

    if (_selectedAuthTab == 0) {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        setState(() => _errorText = 'Phone number is required');
        return;
      }
      if (phone.length < 10) {
        setState(() => _errorText = 'Enter valid 10-digit mobile number');
        return;
      }

      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.push('/auth/otp', extra: phone);
        }
      });
    } else {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        setState(() => _errorText = 'Enter a valid email address');
        return;
      }

      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isLoading = false);
          context.go('/auth/profile-setup');
        }
      });
    }
  }

  void _handleSocialLogin(String provider) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/home');
      }
    });
  }

  void _showAccountRecoveryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF00C853)),
                ),
                const SizedBox(width: 12),
                Text(
                  'Account Recovery',
                  style: GoRushTypography.headline.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Having trouble accessing your GoRush account? Select a recovery method:',
              style: GoRushTypography.body.copyWith(color: GoRushColors.textSecondary),
            ),
            const SizedBox(height: 20),

            _buildRecoveryOption(
              icon: Icons.email_outlined,
              title: 'Recover via Email OTP',
              subtitle: 'Send verification code to registered email',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Recovery link sent to your email')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildRecoveryOption(
              icon: Icons.phone_android_rounded,
              title: 'Lost Phone Number?',
              subtitle: 'Verify Govt ID to update mobile number',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support team will verify your identity')),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildRecoveryOption(
              icon: Icons.support_agent_rounded,
              title: 'Contact GoRush Support',
              subtitle: '24/7 Priority Assistance & Account Claims',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to Customer Support agent...')),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: GoRushColors.border),
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFFF9FAFB),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00C853), size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoRushTypography.title.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoRushTypography.caption.copyWith(color: GoRushColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
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
                          Colors.white.withValues(alpha: 0.88),
                          Colors.white.withValues(alpha: 0.65),
                          Colors.white.withValues(alpha: 0.98),
                        ],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.xl, vertical: GoRushSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/auth/welcome');
                                  }
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
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

                              TextButton.icon(
                                onPressed: _showAccountRecoveryModal,
                                icon: const Icon(Icons.help_outline_rounded, size: 16, color: Color(0xFF00C853)),
                                label: Text(
                                  'Recovery',
                                  style: GoRushTypography.caption.copyWith(
                                    color: const Color(0xFF00C853),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GoRushSpacing.md),

                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C853).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF00C853).withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Color(0xFF00C853),
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.md),

                          Text(
                            'Sign in to GoRush',
                            style: GoRushTypography.display.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: GoRushColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access Fast & Safe Rides in Seconds',
                            style: GoRushTypography.body.copyWith(
                              color: GoRushColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.lg),

                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildAuthTab(
                                    index: 0,
                                    icon: Icons.phone_android_rounded,
                                    label: 'Mobile OTP',
                                  ),
                                ),
                                Expanded(
                                  child: _buildAuthTab(
                                    index: 1,
                                    icon: Icons.email_outlined,
                                    label: 'Email',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.lg),

                          if (_selectedAuthTab == 0) ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(GoRushRadius.lg),
                                border: Border.all(
                                  color: _errorText != null
                                      ? GoRushColors.error
                                      : const Color(0xFF00C853).withValues(alpha: 0.3),
                                  width: _errorText != null ? 1.5 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C853).withValues(alpha: 0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(GoRushRadius.md),
                                    ),
                                    child: Row(
                                      children: [
                                        const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+91',
                                          style: GoRushTypography.title.copyWith(
                                            color: const Color(0xFF00C853),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: GoRushSpacing.md),
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 10,
                                      autofocus: true,
                                      style: GoRushTypography.headline.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '98765 43210',
                                        counterText: '',
                                        filled: false,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintStyle: GoRushTypography.title.copyWith(
                                          color: GoRushColors.textMuted,
                                          letterSpacing: 1.5,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(GoRushRadius.lg),
                                border: Border.all(
                                  color: const Color(0xFF00C853).withValues(alpha: 0.3),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              child: TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: GoRushTypography.title.copyWith(fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Enter your email address',
                                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF00C853)),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                          ],

                          if (_errorText != null) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                _errorText!,
                                style: GoRushTypography.caption.copyWith(color: GoRushColors.error),
                              ),
                            ),
                          ],

                          const SizedBox(height: GoRushSpacing.md),

                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _whatsappConsent,
                                  activeColor: const Color(0xFF00C853),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) => setState(() => _whatsappConsent = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Get trip updates & receipts on WhatsApp',
                                  style: GoRushTypography.caption.copyWith(
                                    color: GoRushColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: GoRushSpacing.md),

                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey[300])),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR SOCIAL SIGN-IN',
                                  style: GoRushTypography.caption.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: GoRushColors.textMuted,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey[300])),
                            ],
                          ),
                          const SizedBox(height: GoRushSpacing.md),

                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleSocialLogin('google'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  icon: const Icon(Icons.g_mobiledata_rounded, color: Colors.redAccent, size: 28),
                                  label: const Text('Google', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleSocialLogin('apple'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  icon: const Icon(Icons.apple_rounded, color: Colors.black, size: 24),
                                  label: const Text('Apple', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: GoRushColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF00C853)),
                                const SizedBox(width: 6),
                                Text(
                                  '256-Bit Encrypted Session • Privacy Protected',
                                  style: GoRushTypography.caption.copyWith(
                                    fontSize: 11,
                                    color: GoRushColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: GoRushSpacing.md),

                          Center(
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: GoRushTypography.caption.copyWith(
                                  color: GoRushColors.textSecondary,
                                  height: 1.35,
                                  fontSize: 11,
                                ),
                                children: const [
                                  TextSpan(text: 'By continuing, you agree to GoRush '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: Color(0xFF00C853),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: Color(0xFF00C853),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.sm),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(GoRushRadius.md),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF00C853).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: GoRushButton(
                                label: _selectedAuthTab == 0 ? 'Send Verification Code' : 'Continue with Email',
                                isLoading: _isLoading,
                                onPressed: _validateAndSubmit,
                              ),
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.sm),
                        ],
                      ),
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

  Widget _buildAuthTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedAuthTab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedAuthTab = index;
        _errorText = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF00C853) : GoRushColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF00C853) : GoRushColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

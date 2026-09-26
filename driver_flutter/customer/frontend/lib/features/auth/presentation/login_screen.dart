import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/widgets/buttons/gorush_button.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';
import '../domain/auth_repository.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const LoginScreen({super.key, this.authRepository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AuthRepository _authRepository;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final res = await _authRepository.loginWithPassword(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final userMap = res['user'] ?? {};
      final userId = userMap['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userName = userMap['name'] ?? 'Rider';
      final userEmail = userMap['email'] ?? '';
      final userPhone = userMap['phoneNumber'] ?? '';

      HttpUserRepository.setActiveUser(
        UserProfileModel(
          userId: userId,
          name: userName,
          email: userEmail,
          phone: userPhone,
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
          gender: 'Male',
          memberTier: 'GOLD',
          memberSince: 'January 2026',
          emergencyContacts: [],
          rating: 4.95,
          totalTrips: 12,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome back, $userName! Logged in successfully.',
                  style: GoRushTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isLoading = false;
        _errorMessage = cleanMsg;
      });
    }
  }

  void _showForgotPasswordModal() {
    final TextEditingController recoverController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
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
                    color: Colors.grey.shade300,
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
                    'Reset Password',
                    style: GoRushTypography.headline.copyWith(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your registered Phone Number or Email address to receive a password reset OTP.',
                style: GoRushTypography.body.copyWith(color: const Color(0xFF475569), fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: recoverController,
                style: GoRushTypography.body.copyWith(color: const Color(0xFF0F172A)),
                decoration: InputDecoration(
                  hintText: 'Phone number or Email',
                  hintStyle: GoRushTypography.body.copyWith(color: const Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.contact_mail_outlined, color: Color(0xFF00C853)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF00C853), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GoRushButton(
                label: 'Send Reset Code',
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Password reset OTP sent to ${recoverController.text.isEmpty ? "registered number" : recoverController.text}',
                        style: GoRushTypography.body.copyWith(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF00C853),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C853).withValues(alpha: 0.12),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/phone_auth_bg.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // Crisp Light Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.90),
                          Colors.white.withValues(alpha: 0.72),
                          Colors.white.withValues(alpha: 0.96),
                        ],
                      ),
                    ),
                  ),
                ),

                // Main Content
                SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        // App Bar / Top Navigation
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.md, vertical: GoRushSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
                                tooltip: 'Back',
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00C853),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.flash_on_rounded, color: Colors.black, size: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'GoRush',
                                    style: GoRushTypography.headline.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 40),
                            ],
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: GoRushSpacing.xl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Header Text
                                  Text(
                                    'Welcome Back 👋',
                                    style: GoRushTypography.display.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: GoRushSpacing.xs),
                                  Text(
                                    'Log in using your registered Email/Phone & Password to access your GoRush account.',
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF475569),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: GoRushSpacing.xxl),

                                  if (_errorMessage != null) ...[
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFFCA5A5)),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 22),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: GoRushTypography.caption.copyWith(
                                                color: const Color(0xFFB91C1C),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: GoRushSpacing.md),
                                  ],

                                  // Identifier Field (Phone / Email)
                                  Text(
                                    'Phone Number or Email',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _identifierController,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: 'e.g. 9876543210 or user@example.com',
                                      icon: Icons.alternate_email_rounded,
                                    ),
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter phone number or email' : null,
                                  ),

                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Password Field
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Password',
                                        style: GoRushTypography.caption.copyWith(
                                          color: const Color(0xFF334155),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _showForgotPasswordModal,
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoRushTypography.caption.copyWith(
                                            color: const Color(0xFF00C853),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: 'Enter password',
                                      icon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: const Color(0xFF64748B),
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (val) => val == null || val.isEmpty ? 'Enter password' : null,
                                  ),

                                  const SizedBox(height: GoRushSpacing.xxl),

                                  // Submit Button
                                  GoRushButton(
                                    label: 'Log In to GoRush',
                                    isLoading: _isLoading,
                                    onPressed: _handleLogin,
                                  ),

                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Don't have an account -> Register
                                  Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'New to GoRush? ',
                                          style: GoRushTypography.body.copyWith(
                                            color: const Color(0xFF475569),
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push('/auth/register'),
                                          child: Text(
                                            'Create Account',
                                            style: GoRushTypography.title.copyWith(
                                              color: const Color(0xFF00C853),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              decorationColor: const Color(0xFF00C853),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          'OR',
                                          style: GoRushTypography.caption.copyWith(
                                            color: const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                                    ],
                                  ),

                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Use Phone OTP instead
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push('/auth/phone'),
                                      icon: const Icon(Icons.phonelink_ring_rounded, color: Color(0xFF0F172A), size: 18),
                                      label: Text(
                                        'Sign In with Phone OTP',
                                        style: GoRushTypography.title.copyWith(
                                          color: const Color(0xFF0F172A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white.withValues(alpha: 0.8),
                                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: GoRushSpacing.xl),
                                ],
                              ),
                            ),
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

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoRushTypography.body.copyWith(color: const Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF00C853), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/widgets/buttons/gorush_button.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';
import '../domain/auth_repository.dart';

class RegistrationScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const RegistrationScreen({super.key, this.authRepository});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late final AuthRepository _authRepository;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await _authRepository.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final userMap = res['user'] ?? {};
      final userId = userMap['id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final userName = userMap['name'] ?? _nameController.text.trim();
      final userEmail = userMap['email'] ?? _emailController.text.trim();
      final userPhone = userMap['phoneNumber'] ?? _phoneController.text.trim();

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
          rating: 5.0,
          totalTrips: 0,
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
                  'Account created for $userName! Welcome to GoRush.',
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
                                    'Create Account 🚀',
                                    style: GoRushTypography.display.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: GoRushSpacing.xs),
                                  Text(
                                    'Register once with your details to log in anytime securely without OTP.',
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF475569),
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: GoRushSpacing.xl),

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

                                  // Name Field
                                  Text(
                                    'Full Name',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: 'e.g. Rahul Sharma',
                                      icon: Icons.person_outline_rounded,
                                    ),
                                    validator: (val) => val == null || val.trim().isEmpty ? 'Enter your full name' : null,
                                  ),

                                  const SizedBox(height: GoRushSpacing.md),

                                  // Email Field
                                  Text(
                                    'Email Address',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: 'rahul@example.com',
                                      icon: Icons.email_outlined,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Enter your email address';
                                      if (!val.contains('@') || !val.contains('.')) return 'Enter a valid email';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: GoRushSpacing.md),

                                  // Phone Field
                                  Text(
                                    'Mobile Phone Number',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: '9876543210',
                                      icon: Icons.phone_android_rounded,
                                      prefixText: '+91  ',
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Enter mobile number';
                                      if (val.trim().length < 10) return 'Enter 10-digit mobile number';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: GoRushSpacing.md),

                                  // Password Field
                                  Text(
                                    'Create Password',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
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
                                      hint: 'At least 6 characters',
                                      icon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: const Color(0xFF64748B),
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Enter password';
                                      if (val.length < 6) return 'Password must be at least 6 characters';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: GoRushSpacing.md),

                                  // Confirm Password Field
                                  Text(
                                    'Confirm Password',
                                    style: GoRushTypography.caption.copyWith(
                                      color: const Color(0xFF334155),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    style: GoRushTypography.body.copyWith(
                                      color: const Color(0xFF0F172A),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: _buildInputDecoration(
                                      hint: 'Repeat password',
                                      icon: Icons.lock_clock_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                          color: const Color(0xFF64748B),
                                        ),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return 'Confirm your password';
                                      return null;
                                    },
                                  ),

                                  const SizedBox(height: GoRushSpacing.xl),

                                  // Submit Button
                                  GoRushButton(
                                    label: 'Create GoRush Account',
                                    isLoading: _isLoading,
                                    onPressed: _handleRegister,
                                  ),

                                  const SizedBox(height: GoRushSpacing.lg),

                                  // Already have account -> Login
                                  Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Already registered? ',
                                          style: GoRushTypography.body.copyWith(
                                            color: const Color(0xFF475569),
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.push('/auth/login'),
                                          child: Text(
                                            'Log In with Password',
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

                                  const SizedBox(height: GoRushSpacing.md),

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

                                  const SizedBox(height: GoRushSpacing.md),

                                  // Use Phone OTP instead
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: OutlinedButton.icon(
                                      onPressed: () => context.push('/auth/phone'),
                                      icon: const Icon(Icons.phonelink_ring_rounded, color: Color(0xFF0F172A), size: 18),
                                      label: Text(
                                        'Continue with Phone OTP',
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
    String? prefixText,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoRushTypography.body.copyWith(color: const Color(0xFF94A3B8)),
      prefixIcon: Icon(icon, color: const Color(0xFF00C853), size: 20),
      prefixText: prefixText,
      prefixStyle: GoRushTypography.body.copyWith(color: const Color(0xFF0F172A), fontWeight: FontWeight.bold),
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

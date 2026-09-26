import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/tokens.dart';
import '../../../shared/theme/typography.dart';
import '../../../shared/widgets/buttons/gorush_button.dart';
import '../../../core/user/data/user_repository.dart';
import '../../../core/user/domain/user_models.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  bool _notificationsConsent = true;

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

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    HttpUserRepository.setActiveUser(
      UserProfileModel(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email.isNotEmpty ? email : '$name@gorush.app',
        phone: '+91 98765 43210',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde',
        gender: 'Male',
        memberTier: 'GOLD',
        memberSince: 'January 2026',
        emergencyContacts: [],
        rating: 5.0,
        totalTrips: 0,
      ),
    );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        context.go('/home');
      }
    });
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
                color: const Color(0xFF00C853).withValues(alpha: 0.18),
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
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  'Profile Setup',
                                  style: GoRushTypography.headline.copyWith(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: GoRushColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customize your GoRush account',
                                  style: GoRushTypography.caption.copyWith(
                                    color: GoRushColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.xl),

                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF00C853),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00C853).withValues(alpha: 0.2),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    size: 58,
                                    color: Color(0xFF00C853),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C853),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.xxl),

                          Text(
                            'Full Name',
                            style: GoRushTypography.title.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: GoRushColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(GoRushRadius.md),
                              border: Border.all(
                                color: const Color(0xFF00C853).withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: TextField(
                              controller: _nameController,
                              style: GoRushTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Rahul Kumar',
                                prefixIcon: Icon(Icons.person_outline_rounded, color: Color(0xFF00C853)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.lg),

                          Text(
                            'Email Address (Optional)',
                            style: GoRushTypography.title.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: GoRushColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(GoRushRadius.md),
                              border: Border.all(
                                color: const Color(0xFF00C853).withValues(alpha: 0.4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoRushTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'rahul@example.com',
                                prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF00C853)),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.lg),

                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: _notificationsConsent,
                                  activeColor: const Color(0xFF00C853),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  onChanged: (val) => setState(() => _notificationsConsent = val ?? false),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Receive email trip receipts and promotional offers',
                                  style: GoRushTypography.caption.copyWith(
                                    color: GoRushColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

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
                                label: 'Save & Continue',
                                isLoading: _isLoading,
                                onPressed: _saveProfile,
                              ),
                            ),
                          ),
                          const SizedBox(height: GoRushSpacing.md),
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

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

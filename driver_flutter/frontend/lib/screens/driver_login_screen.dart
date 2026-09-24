import 'package:flutter/material.dart';
import '../core/theme.dart';

class DriverLoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onForgotPasswordTap;
  final VoidCallback? onRegisterTap;
  final VoidCallback? onBackTap;

  const DriverLoginScreen({
    super.key,
    this.onLoginSuccess,
    this.onForgotPasswordTap,
    this.onRegisterTap,
    this.onBackTap,
  });

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final TextEditingController _phoneController = TextEditingController(text: '+91 81224 367641');
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: QuickServeColors.textDark),
                onPressed: widget.onBackTap,
              )
            : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Logo & App Name Header (Phone 19)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'GoRush Driver App',
                      style: TextStyle(
                        color: QuickServeColors.textDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title: Welcome Back!
              const Text(
                'Welcome Back!',
                style: TextStyle(
                  color: QuickServeColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Login to your account to start accepting rides',
                style: TextStyle(
                  color: QuickServeColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 28),

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

              const SizedBox(height: 16),

              // Password Input
              const Text(
                'Password',
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
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(
                    color: QuickServeColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: QuickServeColors.textSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: QuickServeColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onForgotPasswordTap,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: QuickServeColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login CTA Button
              ElevatedButton(
                onPressed: widget.onLoginSuccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: QuickServeColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  shadowColor: QuickServeColors.primaryBlue.withOpacity(0.3),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 32),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: QuickServeColors.textSecondary, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: widget.onRegisterTap,
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: QuickServeColors.primaryBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

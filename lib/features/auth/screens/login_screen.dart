// lib/features/auth/screens/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _login() async {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _loading = false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
    }
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestColors.void_black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.3, -0.6),
                  radius: 1.2,
                  colors: [Color(0xFF0F2008), ZestColors.void_black],
                ),
              ),
            ),
          ),
          Positioned(
            top: -80, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  ZestColors.lemonGreen.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: ZestColors.lemonGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: ZestColors.void_black, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Text('ZestChat',
                          style: TextStyle(
                            color: ZestColors.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          )),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                  const SizedBox(height: 48),
                  Text('Welcome\nback.',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge!
                          .copyWith(height: 1.1))
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.1),
                  const SizedBox(height: 8),
                  const Text('Sign in to continue.',
                      style: TextStyle(
                          color: ZestColors.textSecondary, fontSize: 15))
                      .animate()
                      .fadeIn(delay: 150.ms),
                  const SizedBox(height: 40),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        AuthField(
                            controller: _userCtrl,
                            hint: '@username',
                            icon: Icons.alternate_email_rounded),
                        const SizedBox(height: 12),
                        AuthField(
                          controller: _passCtrl,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: ZestColors.textTertiary,
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthPrimaryBtn(
                          label: 'Sign In',
                          loading: _loading,
                          onTap: _login,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                          style:
                              TextStyle(color: ZestColors.textSecondary)),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text('Sign Up',
                            style: TextStyle(
                              color: ZestColors.lemonGreen,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared auth widgets (used by both Login and Register) ────────────────────

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: ZestColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: ZestColors.textTertiary, size: 18),
        suffixIcon: suffix,
      ),
    );
  }
}

class AuthPrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const AuthPrimaryBtn({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color:
              loading ? ZestColors.lemonGreenDim : ZestColors.lemonGreen,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ZestColors.void_black,
                  ),
                )
              : Text(label,
                  style: const TextStyle(
                    color: ZestColors.void_black,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  )),
        ),
      ),
    );
  }
}

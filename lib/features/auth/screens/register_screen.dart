// lib/features/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/glass_widgets.dart';
import 'login_screen.dart' show AuthField, AuthPrimaryBtn;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
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
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ZestColors.void_black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: ZestColors.textPrimary),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Create account.',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 6),
              const Text('Join ZestChat today.',
                  style: TextStyle(
                      color: ZestColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 32),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AuthField(
                        controller: _nameCtrl,
                        hint: 'Display Name',
                        icon: Icons.badge_outlined),
                    const SizedBox(height: 12),
                    AuthField(
                        controller: _userCtrl,
                        hint: '@username',
                        icon: Icons.alternate_email_rounded),
                    const SizedBox(height: 12),
                    AuthField(
                        controller: _passCtrl,
                        hint: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscure: true),
                    const SizedBox(height: 20),
                    AuthPrimaryBtn(
                        label: 'Create Account',
                        loading: _loading,
                        onTap: _register),
                  ],
                ),
              ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';
import 'sign_in_page.dart';
import 'home_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) => user == null ? const SignInPage() : const HomePage(),
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Auth error: $error', style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/core/widgets/custom_snackbar.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_state.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.log_out, color: Colors.white),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  LucideIcons.mail_search,
                  color: colorScheme.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Verify Your Email',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ve sent a verification link to your email address. Please check your inbox and follow the link to complete your registration.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: colorScheme.onSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    CustomSnackBar.showError(context, state.message);
                  } else if (state is AuthAuthenticated) {
                    CustomSnackBar.showSuccess(
                      context,
                      'Email verified successfully!',
                    );
                  }
                },
                builder: (context, state) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () => context
                                    .read<AuthCubit>()
                                    .checkEmailVerification(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: state is AuthLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'I\'ve Verified My Email',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                context
                                    .read<AuthCubit>()
                                    .resendVerificationEmail();
                                CustomSnackBar.showSuccess(
                                  context,
                                  'Verification email resent!',
                                );
                              },
                        child: Text(
                          'Resend Verification Email',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_ai/core/utils/auth_validator.dart';
import 'package:task_ai/core/widgets/custom_input_field.dart';
import 'package:task_ai/core/widgets/custom_snackbar.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:task_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:task_ai/features/auth/presentation/widgets/auth_field_label.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onResetPassword(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().resetPassword(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrow_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.key_round,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reset Password',
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your email and we\'ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                const AuthFieldLabel(text: 'EMAIL'),
                const SizedBox(height: 8),
                CustomTextFormField(
                  hintText: 'name@example.com',
                  validator: AuthValidator.emailValidator,
                  controller: _emailController,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 32),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      CustomSnackBar.showError(context, state.message);
                    } else if (state is AuthPasswordResetSent) {
                      CustomSnackBar.showSuccess(
                        context,
                        'Password reset link sent to your email.',
                      );
                      Navigator.pop(context);
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => _onResetPassword(context),
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
                                'Send Reset Link',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

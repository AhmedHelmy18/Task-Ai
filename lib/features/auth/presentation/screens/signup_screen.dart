import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:whale_task/core/utils/auth_validator.dart';
import 'package:whale_task/core/widgets/custom_input_field.dart';
import 'package:whale_task/core/widgets/custom_snackbar.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:whale_task/features/auth/presentation/cubit/auth_state.dart';
import 'package:whale_task/features/auth/presentation/widgets/auth_divider.dart';
import 'package:whale_task/features/auth/presentation/widgets/auth_field_label.dart';
import 'package:whale_task/features/auth/presentation/widgets/social_login_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onCreateAccount(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
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
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.sparkles,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Join the Future of Work',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let AI handle the organization, you handle the doing.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: colorScheme.onSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                const AuthFieldLabel(text: 'Full Name'),
                const SizedBox(height: 8),
                CustomTextFormField(
                  hintText: 'John Doe',
                  validator: AuthValidator.nameValidator,
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 24),
                const AuthFieldLabel(text: 'Email Address'),
                const SizedBox(height: 8),
                CustomTextFormField(
                  hintText: 'name@example.com',
                  validator: AuthValidator.emailValidator,
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 24),
                const AuthFieldLabel(text: 'Password'),
                const SizedBox(height: 8),
                CustomTextFormField(
                  hintText: 'min. 8 characters',
                  validator: AuthValidator.passwordValidator,
                  controller: _passwordController,
                  textInputAction: TextInputAction.done,
                  isPasswordField: true,
                ),
                const SizedBox(height: 32),
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      CustomSnackBar.showError(context, state.message);
                    } else if (state is AuthAuthenticated ||
                        state is AuthNeedsVerification) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () => _onCreateAccount(context),
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(LucideIcons.arrow_right, size: 18),
                                ],
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const AuthDivider(text: 'Or sign up with'),
                const SizedBox(height: 32),
                SocialLoginButton(
                  label: 'Google',
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                ),
                const SizedBox(height: 32),
                _buildTermsText(colorScheme),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GoogleFonts.inter(color: colorScheme.onSecondary),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: GoogleFonts.inter(
            fontSize: 12,
            color: colorScheme.onSecondary.withAlpha(150),
            height: 1.5,
          ),
          children: [
            const TextSpan(text: 'By creating an account, you agree to our '),
            TextSpan(
              text: 'Terms of Service',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: ' and '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}

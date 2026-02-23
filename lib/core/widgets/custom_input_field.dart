import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.hintText,
    required this.validator,
    required this.controller,
    this.isPasswordField = false,
    this.keyboardType = TextInputType.emailAddress,
    required this.textInputAction,
    this.icon,
    this.autofocus = false,
  });

  final String hintText;
  final bool isPasswordField;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final TextInputAction textInputAction;
  final IconData? icon;
  final bool autofocus;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormField();
}

class _CustomTextFormField extends State<CustomTextFormField> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: widget.textInputAction,
      cursorColor: colorScheme.primary,
      autofocus: widget.autofocus,
      obscureText: widget.isPasswordField && !isVisible ? true : false,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withAlpha(10),
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          color: colorScheme.onSecondary.withAlpha(100),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withAlpha(10)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.primary.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.error.withAlpha(100)),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: widget.isPasswordField == true
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                icon: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: colorScheme.onSecondary.withAlpha(150),
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}

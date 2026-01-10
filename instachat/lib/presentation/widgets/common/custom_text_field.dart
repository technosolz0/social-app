import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================
// lib/presentation/widgets/common/custom_text_field.dart
// 🎨 REUSABLE TEXT FIELD WIDGET
// ============================================

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final bool filled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.fillColor,
    this.filled = false,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.errorBorder,
    this.style,
    this.labelStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      autofocus: autofocus,
      focusNode: focusNode,
      style: style ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        fillColor: fillColor ?? theme.inputDecorationTheme.fillColor,
        filled: filled,
        border: border ?? theme.inputDecorationTheme.border,
        enabledBorder: enabledBorder ?? theme.inputDecorationTheme.enabledBorder,
        focusedBorder: focusedBorder ?? theme.inputDecorationTheme.focusedBorder,
        errorBorder: errorBorder ?? theme.inputDecorationTheme.errorBorder,
        labelStyle: labelStyle ?? theme.inputDecorationTheme.labelStyle,
        hintStyle: hintStyle ?? theme.inputDecorationTheme.hintStyle,
      ),
    );
  }
}

// ============================================
// COMMON TEXT FIELD VARIANTS
// ============================================

class AuthTextField extends CustomTextField {
  AuthTextField({
    super.key,
    super.controller,
    required String labelText,
    String? hintText,
    super.errorText,
    super.prefixIcon,
    super.suffixIcon,
    super.obscureText = false,
    super.keyboardType,
    super.textInputAction,
    super.onChanged,
    super.onSubmitted,
    super.validator,
    super.inputFormatters,
    super.autofocus,
    super.focusNode,
  }) : super(
          labelText: labelText,
          hintText: hintText ?? 'Enter $labelText',
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        );
}

class SearchTextField extends CustomTextField {
  SearchTextField({
    super.key,
    super.controller,
    String hintText = 'Search...',
    super.onChanged,
    super.onSubmitted,
    super.focusNode,
  }) : super(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
        );
}

class CommentTextField extends CustomTextField {
  CommentTextField({
    super.key,
    super.controller,
    String hintText = 'Add a comment...',
    super.onChanged,
    super.onSubmitted,
    super.maxLines = 3,
    super.minLines = 1,
  }) : super(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue, width: 1),
          ),
        );
}

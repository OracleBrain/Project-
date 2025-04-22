import 'package:flutter/material.dart';
import 'package:teacher_attendance_app/utils/theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  
  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
  }) : assert(controller == null || initialValue == null, 
      'Cannot provide both a controller and an initialValue');

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
      style: TextStyle(
        color: enabled
            ? Theme.of(context).textTheme.bodyLarge?.color
            : AppTheme.textGrayColor,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }
}
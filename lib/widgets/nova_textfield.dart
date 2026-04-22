import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/fonts.dart';

class NovaTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isObscure;
  final String? errorText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final VoidCallback? onSuffixIconPressed; // Thêm dòng này

  const NovaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.isObscure = false,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onSuffixIconPressed, // Thêm dòng này
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      cursorColor: Colors.white,
      style: NovaFonts.body.copyWith(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        prefixIcon: icon != null
            ? Icon(icon, color: Colors.white54, size: 20)
            : null,
        // Thêm SuffixIcon để ẩn/hiện mật khẩu
        suffixIcon: onSuffixIconPressed != null
            ? IconButton(
                icon: Icon(
                  isObscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,
        labelText: label,
        labelStyle: NovaFonts.body.copyWith(
          color: NovaColors.textSecondary,
          fontSize: 14,
        ),
        errorText: errorText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}

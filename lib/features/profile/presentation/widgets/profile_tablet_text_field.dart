import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Form text field customized for Tablet Landscape with fixed padding and crisp typography.
class ProfileTabletTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool isPassword;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final void Function(String)? onChanged;

  const ProfileTabletTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.isPassword = false,
    this.readOnly = false,
    this.suffixIcon,
    this.controller,
    this.onChanged,
  });

  @override
  State<ProfileTabletTextField> createState() => _ProfileTabletTextFieldState();
}

class _ProfileTabletTextFieldState extends State<ProfileTabletTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          widget.label,
          style: font14w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          onChanged: widget.onChanged,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          style: font14w500.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: font14w500.copyWith(
              color: const Color(0xFF9CA3AF),
              fontSize: 13,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppLightColors.primary,
                width: 1.5,
              ),
            ),
            filled: true,
            fillColor: widget.readOnly ? const Color(0xFFF8FAFC) : Colors.white,
          ),
        ),
      ],
    );
  }
}

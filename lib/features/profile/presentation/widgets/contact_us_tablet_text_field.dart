import 'package:flutter/material.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Form field tailored for Contact Us in Tablet Landscape with crisp, fixed typography.
class ContactUsTabletTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const ContactUsTabletTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final Widget styledIcon = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: Icon(icon, color: AppLightColors.primary, size: 17)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          label,
          style: font14w700.copyWith(
            color: const Color(0xFF1E1E2D),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        if (maxLines > 1)
          Stack(
            children: [
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                style: font14w500.copyWith(
                  color: const Color(0xFF1E1E2D),
                  fontSize: 13.5,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: font14w500.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                  contentPadding: const EdgeInsets.only(
                    top: 12,
                    bottom: 12,
                    right: 46, // Space for icon on right in RTL
                    left: 14,
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
                  fillColor: Colors.white,
                ),
              ),
              Positioned(top: 8, right: 8, child: styledIcon),
            ],
          )
        else
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: 1,
            style: font14w500.copyWith(
              color: const Color(0xFF1E1E2D),
              fontSize: 13.5,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: font14w500.copyWith(
                color: const Color(0xFF9CA3AF),
                fontSize: 13,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(
                  left: 10,
                  right: 8,
                  top: 5,
                  bottom: 5,
                ),
                child: styledIcon,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 46,
                minHeight: 38,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
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
              fillColor: Colors.white,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pythagoras/core/constants/app_assets.dart';
import 'package:pythagoras/core/theme/light_colors.dart';
import 'package:pythagoras/core/theme/styles.dart';
import 'package:pythagoras/core/widgets/app_asset.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';

/// Professional Navigation Sidebar for Tablet Landscape.
/// Uses the authentic full-color 3D assets from the mobile navigation bar.
class TabletNavigationSidebar extends StatelessWidget {
  final List<Map<String, dynamic>> navItems;
  final int selectedIndex;
  final Function(int) onItemTapped;

  const TabletNavigationSidebar({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 215,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: BorderDirectional(
          end: BorderSide(color: Color(0xFFEEEEF2), width: 1.2),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),

            // App Brand Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppLightColors.primary,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppLightColors.primary.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(Assets.logoapp, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "فيثاغورس",
                          style: font16w700.copyWith(
                            color: AppLightColors.primary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AppText(
                          "منصة الرياضيات",
                          style: font12w500.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),

            // Navigation Items List
            Expanded(
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: navItems.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  final item = navItems[index];

                  return InkWell(
                    onTap: () => onItemTapped(index),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppLightColors.primary.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppLightColors.primary.withValues(alpha: 0.22)
                              : Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: isSelected ? 1.0 : 0.8,
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: AppAsset(
                                assetName: item['imageAsset'] as String,
                                width: 28,
                                height: 28,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppText(
                              item['label'] as String,
                              style: font14w700.copyWith(
                                color: isSelected
                                    ? AppLightColors.primary
                                    : const Color(0xFF475569),
                                fontSize: 14.5,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppLightColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:pythagoras/core/widgets/nav_bar_item.dart';
import 'package:pythagoras/core/widgets/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List<Map<String, dynamic>> navItems;
  final NavigationState navState;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.navItems,
    required this.navState,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 25.r,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              return NavBarItem(
                imageAsset: navItems[index]['imageAsset'],
                label: navItems[index]['label'],
                isSelected: navState.selectedIndex == index,
                onTap: () {
                  onItemTapped(index);
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

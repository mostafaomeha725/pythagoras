import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/utils/responsive_helper.dart';

import 'ios_register_form.dart';
import 'ios_register_header.dart';
import 'ios_register_login_link.dart';

class IosRegisterDefaultLayout extends StatelessWidget {
  const IosRegisterDefaultLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveHelper.isTablet(context);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : double.infinity,
              ),
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 48),
                    IosRegisterHeader(showBackButton: false),
                    SizedBox(height: 20),
                    IosRegisterForm(key: ValueKey('default_ios_register_form')),
                    SizedBox(height: 20),
                    IosRegisterLoginLink(tabletLandscape: false),
                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Pinned AppBar Back Button
        PositionedDirectional(
          top: 12.h,
          start: 20.w,
          child: IosRegisterHeader.backButton(
            context,
            size: 38.w,
            iconSize: 18.sp,
            borderRadius: 50.r,
          ),
        ),
      ],
    );
  }
}

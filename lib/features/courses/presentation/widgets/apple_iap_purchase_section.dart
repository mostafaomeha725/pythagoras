import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_action_spacing.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';

class AppleIapPurchaseSection extends StatelessWidget {
  final AppleIapProductType type;
  final int contentId;
  final bool isRequestStatusEligible;
  final bool isEnrolled;
  final bool hasPendingRequest;
  final bool tabletLandscape;

  const AppleIapPurchaseSection({
    super.key,
    required this.type,
    required this.contentId,
    this.isRequestStatusEligible = false,
    this.isEnrolled = false,
    this.hasPendingRequest = false,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform != TargetPlatform.iOS) {
      debugPrint(
        '[IAP][Section] hidden: platform=${Theme.of(context).platform}',
      );
      return const SizedBox.shrink();
    }

    final matchingProductIds = AppleIapProductCatalog.products.entries
        .where(
          (entry) =>
              entry.value.type == type && entry.value.contentId == contentId,
        )
        .map((entry) => entry.key)
        .toSet();
    if (matchingProductIds.isEmpty) {
      debugPrint(
        '[IAP][Section] hidden: no catalog product for $type/$contentId',
      );
      return const SizedBox.shrink();
    }

    return BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (context, remoteConfigState) {
        if (!remoteConfigState.iosIapEnabled) {
          debugPrint('[IAP][Section] hidden: ios_iap_enabled=false');
          return const SizedBox.shrink();
        }

        return BlocBuilder<AppleIapCubit, AppleIapState>(
          builder: (context, state) {
            final products = state.products
                .where((product) => matchingProductIds.contains(product.id))
                .toList(growable: false);
            debugPrint(
              '[IAP][Section] course=$contentId status=${state.status} '
              'matchingIds=$matchingProductIds products=${products.map((product) => product.id).toList()}',
            );

            final purchaseEligible =
                isRequestStatusEligible && !isEnrolled && !hasPendingRequest;
            final canPurchase = purchaseEligible && products.isNotEmpty;
            final productUnavailable =
                purchaseEligible &&
                products.isEmpty &&
                state.status == AppleIapStatus.unavailable;
            final isBusy =
                state.status == AppleIapStatus.loading ||
                state.status == AppleIapStatus.purchasing ||
                state.status == AppleIapStatus.pending ||
                state.status == AppleIapStatus.purchaseConfirmed;
            return Padding(
              padding: tabletLandscape
                  ? const EdgeInsets.fromLTRB(16, 0, 16, 0)
                  : EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
              child: Column(
                children: [
                  if (productUnavailable)
                    Padding(
                      padding: EdgeInsets.only(bottom: appleIapActionSpacing.h),
                      child: Text(
                        'الشراء عبر Apple غير متاح حاليًا',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  if (canPurchase) ...[
                    AppButton(
                      text: 'شراء عبر Apple - ${products.first.price}',
                      onPressed: isBusy
                          ? null
                          : () => context.read<AppleIapCubit>().purchase(
                              products.first.id,
                            ),
                      radius: tabletLandscape ? 12 : 12.r,
                      height: tabletLandscape ? 48 : 48.h,
                      textSize: tabletLandscape ? 15 : 15.sp,
                    ),
                    SizedBox(
                      height: tabletLandscape
                          ? appleIapActionSpacing
                          : appleIapActionSpacing.h,
                    ),
                  ],
                  AppButton(
                    text: 'استعادة المشتريات',
                    onPressed: isBusy
                        ? null
                        : () =>
                              context.read<AppleIapCubit>().restorePurchases(),
                    radius: tabletLandscape ? 12 : 12.r,
                    height: tabletLandscape ? 42 : 42.h,
                    textSize: tabletLandscape ? 13 : 13.sp,
                    color: Colors.transparent,
                    textColor: Theme.of(context).colorScheme.primary,
                    borderColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

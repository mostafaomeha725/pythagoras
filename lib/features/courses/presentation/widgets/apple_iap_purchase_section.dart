import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/utils/auth_guard.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/widgets/apple_iap_action_spacing.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';

class AppleIapPurchaseSection extends StatelessWidget {
  final AppleIapProductType type;
  final int contentId;
  final String? appleProductId;
  final FutureOr<void> Function(String productId)? onPurchase;
  final VoidCallback? onAuthenticated;
  final bool isRequestStatusEligible;
  final bool isEnrolled;
  final bool hasPendingRequest;
  final bool tabletLandscape;

  const AppleIapPurchaseSection({
    super.key,
    required this.type,
    required this.contentId,
    this.appleProductId,
    this.onPurchase,
    this.onAuthenticated,
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

    final productId = appleProductId?.trim();
    final hasProductId = productId != null && productId.isNotEmpty;

    return BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
      builder: (context, remoteConfigState) {
        if (!remoteConfigState.iosIapEnabled) {
          debugPrint('[IAP][Section] hidden: IAP flag disabled for $type');
          return const SizedBox.shrink();
        }

        return BlocBuilder<AppleIapCubit, AppleIapState>(
          builder: (context, state) {
            final products = hasProductId
                ? state.products
                      .where((product) => product.id == productId)
                      .toList(growable: false)
                : const <ProductDetails>[];
            debugPrint(
              '[IAP][Section] type=$type contentId=$contentId status=${state.status} '
              'productId=$productId products=${products.map((product) => product.id).toList()}',
            );

            final purchaseEligible =
                isRequestStatusEligible && !isEnrolled && !hasPendingRequest;
            final blocksCurrentProduct =
                products.any(
                  (product) => product.id == state.activeProductId,
                ) &&
                (state.status == AppleIapStatus.transactionConflict ||
                    state.status == AppleIapStatus.purchaseTimedOut ||
                    state.status == AppleIapStatus.restored);
            final canPurchase =
                purchaseEligible &&
                !products.any(
                  (product) => context
                      .read<AppleIapCubit>()
                      .purchaseNeedsReconciliationFor(product.id),
                ) &&
                !blocksCurrentProduct &&
                products.isNotEmpty;
            final productUnavailable =
                purchaseEligible &&
                products.isEmpty &&
                hasProductId &&
                !context.read<AppleIapCubit>().isProductConfigurationConflict(
                  productId,
                ) &&
                state.status == AppleIapStatus.unavailable;
            final productIdMissing = purchaseEligible && !hasProductId;
            final productConfigurationError =
                purchaseEligible &&
                context.read<AppleIapCubit>().isProductConfigurationConflict(
                  productId,
                );
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
                  if (productIdMissing)
                    Padding(
                      padding: EdgeInsets.only(bottom: appleIapActionSpacing.h),
                      child: Text(
                        'الشراء عبر Apple غير متاح لهذا المحتوى حاليًا',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  if (productConfigurationError)
                    Padding(
                      padding: EdgeInsets.only(bottom: appleIapActionSpacing.h),
                      child: Text(
                        'إعداد الشراء عبر Apple غير صالح لهذا المحتوى. يرجى التواصل مع الدعم.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
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
                          : () => unawaited(
                              _purchase(context, products.first.id),
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
                        : () => unawaited(_restore(context)),
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

  Future<void> _purchase(BuildContext context, String productId) async {
    final didLogin = await AuthGuard.checkAuthAndExecute(context, () async {
      final onPurchase = this.onPurchase;
      if (onPurchase != null) {
        await onPurchase(productId);
      } else {
        await context.read<AppleIapCubit>().purchase(productId);
      }
    });
    if (didLogin && context.mounted) onAuthenticated?.call();
  }

  Future<void> _restore(BuildContext context) async {
    await AuthGuard.checkAuthAndExecute(context, () async {
      await context.read<AppleIapCubit>().restorePurchases();
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pythagoras/core/widgets/custom_button.dart';
import 'package:pythagoras/core/widgets/custom_text.dart';
import 'package:pythagoras/features/courses/data/services/apple_iap_product_catalog.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/apple_iap/apple_iap_state.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_cubit.dart';
import 'package:pythagoras/features/courses/presentation/cubit/remote_config/remote_config_state.dart';

class AppleIapPurchaseSection extends StatelessWidget {
  final AppleIapProductType type;
  final int contentId;
  final bool isEnrolled;
  final bool hasPendingRequest;
  final bool tabletLandscape;

  const AppleIapPurchaseSection({
    super.key,
    required this.type,
    required this.contentId,
    this.isEnrolled = false,
    this.hasPendingRequest = false,
    this.tabletLandscape = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isEnrolled || hasPendingRequest) return const SizedBox.shrink();
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

            if (state.status == AppleIapStatus.unavailable) {
              return _message('الشراء عبر Apple غير متاح حاليًا');
            }
            final statusMessage = switch (state.status) {
              AppleIapStatus.loading => state.message,
              AppleIapStatus.pending => 'جاري انتظار تأكيد عملية الشراء',
              AppleIapStatus.verificationRequired =>
                'تم استلام المعاملة وتحتاج إلى تحقق موثوق',
              AppleIapStatus.restored =>
                state.message ?? 'تمت استعادة المشتريات دون طلب تفعيل جديد',
              AppleIapStatus.restoreEmpty =>
                state.message ?? 'لم يتم العثور على مشتريات سابقة',
              AppleIapStatus.purchaseConfirmed =>
                'تم تأكيد الشراء، وجاري إرسال طلب التفعيل للمراجعة',
              AppleIapStatus.cancelled =>
                state.message ?? 'تم إلغاء عملية الشراء',
              AppleIapStatus.failure =>
                state.message ?? 'تعذر إتمام عملية الشراء',
              _ => null,
            };
            if (products.isEmpty) {
              if (statusMessage != null) return _message(statusMessage);
              debugPrint('[IAP][Section] hidden: no matching products');
              return const SizedBox.shrink();
            }

            final product = products.first;
            final isBusy =
                state.status == AppleIapStatus.loading ||
                state.status == AppleIapStatus.purchasing ||
                state.status == AppleIapStatus.pending ||
                state.status == AppleIapStatus.purchaseConfirmed;
            return Padding(
              padding: tabletLandscape
                  ? const EdgeInsets.fromLTRB(16, 0, 16, 10)
                  : EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
              child: Column(
                children: [
                  if (statusMessage != null) ...[
                    AppText(
                      statusMessage,
                      alignment: AlignmentDirectional.center,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    SizedBox(height: tabletLandscape ? 6 : 6.h),
                  ],
                  AppButton(
                    text: 'شراء عبر Apple - ${product.price}',
                    onPressed: isBusy
                        ? null
                        : () => context.read<AppleIapCubit>().purchase(
                            product.id,
                          ),
                    radius: tabletLandscape ? 12 : 12.r,
                    height: tabletLandscape ? 48 : 48.h,
                    textSize: tabletLandscape ? 15 : 15.sp,
                  ),
                  SizedBox(height: tabletLandscape ? 6 : 6.h),
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

  Widget _message(String message) {
    return Padding(
      padding: tabletLandscape
          ? const EdgeInsets.fromLTRB(16, 0, 16, 10)
          : EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
      child: AppText(
        message,
        alignment: AlignmentDirectional.center,
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
    );
  }
}

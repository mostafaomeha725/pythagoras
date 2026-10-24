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
  final bool tabletLandscape;

  const AppleIapPurchaseSection({
    super.key,
    required this.type,
    required this.contentId,
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

            if (state.status == AppleIapStatus.unavailable) {
              return _message('الشراء عبر Apple غير متاح حاليًا');
            }
            if (state.status == AppleIapStatus.pending) {
              return _message('جاري انتظار تأكيد عملية الشراء');
            }
            if (state.status == AppleIapStatus.verificationRequired) {
              return _message('تم استلام المعاملة وتحتاج إلى تحقق موثوق');
            }
            if (state.status == AppleIapStatus.restored) {
              return _message(
                state.message ?? 'تمت استعادة المشتريات دون طلب تفعيل جديد',
              );
            }
            if (state.status == AppleIapStatus.purchaseConfirmed) {
              return _message(
                'تم تأكيد الشراء، وجاري إرسال طلب التفعيل للمراجعة',
              );
            }
            if (state.status == AppleIapStatus.cancelled) {
              return _message(state.message ?? 'تم إلغاء عملية الشراء');
            }
            if (state.status == AppleIapStatus.failure) {
              return _message(state.message ?? 'تعذر إتمام عملية الشراء');
            }
            if (products.isEmpty) {
              debugPrint('[IAP][Section] hidden: no matching products');
              return const SizedBox.shrink();
            }

            final product = products.first;
            return Padding(
              padding: tabletLandscape
                  ? const EdgeInsets.fromLTRB(16, 0, 16, 10)
                  : EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
              child: Column(
                children: [
                  AppButton(
                    text: 'شراء عبر Apple - ${product.price}',
                    onPressed: state.status == AppleIapStatus.purchasing
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
                    onPressed: state.status == AppleIapStatus.purchasing
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

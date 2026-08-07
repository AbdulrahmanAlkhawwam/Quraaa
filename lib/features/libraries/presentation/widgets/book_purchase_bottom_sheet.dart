import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../auth/auth.dart';
import '../../../cart/cart.dart';
import '../../domain/entities/library_book_entity.dart';

class BookPurchaseBottomSheet extends StatelessWidget {
  const BookPurchaseBottomSheet({super.key, required this.onCheckout});

  final VoidCallback onCheckout;

  static Future<void> show(
    BuildContext context, {
    required LibraryBookEntity? book,
  }) async {
    final bool isAuthenticated =
        await sl<AuthLocalDataSource>().isAuthenticatedSession();
    if (!context.mounted) return;

    if (!isAuthenticated) {
      final bool? shouldLogin = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(LocalizationConstants.settingsGuestLoginTitleKey.tr()),
          content: Text(
            LocalizationConstants.settingsGuestLoginMessageKey.tr(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(LocalizationConstants.commonCancelKey.tr()),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                LocalizationConstants.settingsGuestLoginActionKey.tr(),
              ),
            ),
          ],
        ),
      );
      if (shouldLogin == true && context.mounted) {
        context.goTo(RouteNames.login);
      }
      return;
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (BuildContext sheetContext) => BookPurchaseBottomSheet(
        onCheckout: () async {
          if (book == null || book.listingId.trim().isEmpty) {
            Navigator.of(sheetContext).pop();
            if (context.mounted) {
              context.showResolvedErrorSnackBar(
                LocalizationConstants.libraryBookListingRequiredKey.tr(),
              );
            }
            return;
          }

          final Result<CartSummary> result = await sl<AddCartItemUseCase>()(
            AddCartItemParams(
              listingId: book.listingId,
              metadata: CartItem(
                id: book.listingId,
                title: book.title,
                subtitle: book.author,
                fileSize: '',
                imageUrl: book.coverImageUrl,
                unitPrice: double.tryParse(book.price) ?? 0,
                quantity: 1,
              ),
            ),
          );
          if (!context.mounted || !sheetContext.mounted) return;
          switch (result) {
            case Success<CartSummary>():
              Navigator.of(sheetContext).pop();
              context.pushTo(RouteNames.cart);
            case ResultFailure<CartSummary>(message: final message):
              Navigator.of(sheetContext).pop();
              context.showResolvedErrorSnackBar(message);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.appCard,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.radius28),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.spacing24,
              AppSpacing.spacing20,
              AppSpacing.spacing24,
              AppSpacing.spacing20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        LocalizationConstants.libraryBookPurchaseTitleKey.tr(),
                        style: AppTextStyles.titleLarge.copyWith(
                          color: context.appTextPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: context.isDark
                            ? AppColors.primary300
                            : AppColors.libraryGreen,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing28),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingCart01,
                  color: AppColors.leafGreen,
                  size: 78,
                ),
                const SizedBox(height: AppSpacing.spacing32),
                _PurchaseButton(
                  label: LocalizationConstants.libraryBookCheckoutKey.tr(),
                  filled: true,
                  onPressed: onCheckout,
                ),
                const SizedBox(height: AppSpacing.spacing20),
                _PurchaseButton(
                  label: LocalizationConstants.libraryBookBuyDirectlyKey.tr(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  const _PurchaseButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final OutlinedBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius32),
    );

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: filled
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary600,
                foregroundColor: AppColors.card,
                shape: shape,
              ),
              child: Text(label, style: AppTextStyles.buttonMedium),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.isDark
                    ? AppColors.primary300
                    : AppColors.libraryGreen,
                side: BorderSide(
                  color: context.isDark
                      ? AppColors.primary700
                      : AppColors.primary200,
                ),
                shape: shape,
              ),
              child: Text(label, style: AppTextStyles.buttonMedium),
            ),
    );
  }
}

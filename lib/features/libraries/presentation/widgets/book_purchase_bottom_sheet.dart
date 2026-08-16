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
  const BookPurchaseBottomSheet({
    super.key,
    required this.onCheckout,
    required this.onAddToCart,
  });

  final VoidCallback onCheckout;
  final VoidCallback onAddToCart;

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
      barrierColor: Colors.black.withValues(alpha: 0.38),
      builder: (BuildContext sheetContext) => BookPurchaseBottomSheet(
        onCheckout: () => _handleAction(
          parentContext: context,
          sheetContext: sheetContext,
          book: book,
          checkout: true,
        ),
        onAddToCart: () => _handleAction(
          parentContext: context,
          sheetContext: sheetContext,
          book: book,
          checkout: false,
        ),
      ),
    );
  }

  static Future<void> _handleAction({
    required BuildContext parentContext,
    required BuildContext sheetContext,
    required LibraryBookEntity? book,
    required bool checkout,
  }) async {
    if (book == null || book.listingId.trim().isEmpty) {
      Navigator.of(sheetContext).pop();
      if (parentContext.mounted) {
        parentContext.showResolvedErrorSnackBar(
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
    if (!parentContext.mounted || !sheetContext.mounted) return;

    Navigator.of(sheetContext).pop();
    switch (result) {
      case Success<CartSummary>():
        if (checkout) {
          parentContext.pushTo(RouteNames.cart, extra: true);
        } else {
          parentContext.showSuccessSnackBar(
            message: Message(
              title: LocalizationConstants.cartAddedKey.tr(),
              value: book.title,
            ),
          );
        }
      case ResultFailure<CartSummary>(message: final message):
        parentContext.showResolvedErrorSnackBar(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            AppSpacing.spacing24,
            AppSpacing.spacing24,
            AppSpacing.spacing20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: context.appTextSecondary,
                    size: 23,
                  ),
                ),
              ),
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.16),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedShoppingCart01,
                  color: AppColors.primary500,
                  size: 54,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing24),
              Text(
                LocalizationConstants.cartReadyTitleKey.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.titleLarge.copyWith(
                  color: context.appTextPrimary,
                  fontSize: 23,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 390),
                child: Text(
                  LocalizationConstants.cartReadyMessageKey.tr(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: context.appTextSecondary,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.spacing28),
              _PurchaseButton(
                label: LocalizationConstants.cartCheckoutKey.tr(),
                filled: true,
                onPressed: onCheckout,
              ),
              const SizedBox(height: AppSpacing.spacing14),
              _PurchaseButton(
                label: LocalizationConstants.cartAddToCartKey.tr(),
                onPressed: onAddToCart,
              ),
            ],
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

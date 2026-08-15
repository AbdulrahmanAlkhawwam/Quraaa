import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../libraries/libraries.dart';
import '../../../onboarding/onboarding.dart';
import '../../domain/entities/book_catalog_filter.dart';

class BooksFilterSheet extends StatefulWidget {
  const BooksFilterSheet({required this.initialFilter, super.key});

  final BookCatalogFilter initialFilter;

  @override
  State<BooksFilterSheet> createState() => _BooksFilterSheetState();
}

class _BooksFilterSheetState extends State<BooksFilterSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  List<LibraryEntity> _libraries = const <LibraryEntity>[];
  List<Category> _categories = const <Category>[];
  bool _loadingOptions = true;
  bool _optionsFailed = false;

  String? _libraryId;
  String? _categoryId;
  ListingFormat? _format;
  SellerType? _sellerType;
  BookCondition? _condition;

  @override
  void initState() {
    super.initState();
    final BookCatalogFilter filter = widget.initialFilter;
    _libraryId = filter.libraryId;
    _categoryId = filter.categoryId;
    _format = filter.format;
    _sellerType = filter.sellerType;
    _condition = filter.condition;
    _minPriceController = TextEditingController(
      text: _displayPrice(filter.minPrice),
    );
    _maxPriceController = TextEditingController(
      text: _displayPrice(filter.maxPrice),
    );
    unawaited(_loadOptions());
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    if (!sl.isRegistered<LoadCategoriesUseCase>() ||
        !sl.isRegistered<GetLibrariesUseCase>()) {
      if (mounted) setState(() => _loadingOptions = false);
      return;
    }

    if (mounted) {
      setState(() {
        _loadingOptions = true;
        _optionsFailed = false;
      });
    }

    try {
      final Future<List<Category>> categoriesFuture =
          sl<LoadCategoriesUseCase>()(const NoParams());
      final Future<Result<LibrariesPage>> librariesFuture =
          sl<GetLibrariesUseCase>()(
        const GetLibrariesParams(
          searchTerm: '',
          pageNumber: 1,
          pageSize: 100,
        ),
      );
      final List<Category> categories = await categoriesFuture;
      final Result<LibrariesPage> librariesResult = await librariesFuture;
      final List<LibraryEntity> libraries = switch (librariesResult) {
        Success<LibrariesPage>(value: final LibrariesPage page) => page.items,
        ResultFailure<LibrariesPage>(message: final String message) =>
          throw StateError(message),
      };

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _libraries = libraries;
        _loadingOptions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingOptions = false;
        _optionsFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bool isArabic = context.isRTL;
    final String? validLibraryId = _libraries.any(
      (LibraryEntity item) => item.id == _libraryId,
    )
        ? _libraryId
        : null;
    final String? validCategoryId = _categories.any(
      (Category item) => item.id == _categoryId,
    )
        ? _categoryId
        : null;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: Material(
          color: context.appCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 22, 18, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'books_catalog.filter_title'.tr(),
                          style: AppTextStyles.h3.copyWith(
                            color: context.appTextPrimary,
                            fontSize: 28,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clear,
                        child: Text('books_catalog.clear_filter'.tr()),
                      ),
                      IconButton(
                        key: const Key('books_filter_close'),
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 27),
                        color: context.appTextPrimary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        28,
                        8,
                        28,
                        18,
                      ),
                      children: <Widget>[
                        _FilterLabel('books_catalog.filter.library'.tr()),
                        _FilterDropdown<String>(
                          key: const Key('books_filter_library'),
                          value: validLibraryId,
                          hint: 'books_catalog.filter.choose_library'.tr(),
                          options: _libraries
                              .map(
                                (LibraryEntity library) =>
                                    _DropdownOption<String>(
                                  value: library.id,
                                  label: library.libraryName,
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _loadingOptions
                              ? null
                              : (String? value) =>
                                  setState(() => _libraryId = value),
                        ),
                        const SizedBox(height: 22),
                        _FilterLabel('books_catalog.filter.category'.tr()),
                        _FilterDropdown<String>(
                          key: const Key('books_filter_category'),
                          value: validCategoryId,
                          hint: 'books_catalog.filter.choose_category'.tr(),
                          options: _categories
                              .map(
                                (Category category) => _DropdownOption<String>(
                                  value: category.id,
                                  label: isArabic
                                      ? category.nameAr
                                      : category.nameEn,
                                ),
                              )
                              .toList(growable: false),
                          onChanged: _loadingOptions
                              ? null
                              : (String? value) =>
                                  setState(() => _categoryId = value),
                        ),
                        if (_loadingOptions) ...<Widget>[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(minHeight: 2),
                        ] else if (_optionsFailed) ...<Widget>[
                          const SizedBox(height: 8),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  'books_catalog.filter.options_failed'.tr(),
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _loadOptions,
                                child: Text(
                                  'books_catalog.retry'.tr(),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 22),
                        _FilterLabel('books_catalog.filter.condition'.tr()),
                        _ChoiceWrap<BookCondition>(
                          values: BookCondition.values,
                          selected: _condition,
                          labelBuilder: _conditionLabel,
                          onChanged: (BookCondition? value) =>
                              setState(() => _condition = value),
                        ),
                        const SizedBox(height: 22),
                        _FilterLabel('books_catalog.filter.format'.tr()),
                        _ChoiceWrap<ListingFormat>(
                          values: ListingFormat.values,
                          selected: _format,
                          labelBuilder: _formatLabel,
                          onChanged: (ListingFormat? value) =>
                              setState(() => _format = value),
                        ),
                        const SizedBox(height: 22),
                        _FilterLabel('books_catalog.filter.seller'.tr()),
                        _ChoiceWrap<SellerType>(
                          values: SellerType.values,
                          selected: _sellerType,
                          labelBuilder: _sellerLabel,
                          onChanged: (SellerType? value) =>
                              setState(() => _sellerType = value),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _PriceField(
                                key: const Key('books_filter_min_price'),
                                label: 'books_catalog.filter.min_price'.tr(),
                                controller: _minPriceController,
                                validator: _validateMinPrice,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _PriceField(
                                key: const Key('books_filter_max_price'),
                                label: 'books_catalog.filter.max_price'.tr(),
                                controller: _maxPriceController,
                                validator: _validateMaxPrice,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(28, 8, 28, 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      key: const Key('books_filter_apply'),
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary600,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        'books_catalog.filter.apply'.tr(),
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _clear() {
    setState(() {
      _libraryId = null;
      _categoryId = null;
      _format = null;
      _sellerType = null;
      _condition = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
    _formKey.currentState?.reset();
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.pop(
      context,
      BookCatalogFilter(
        libraryId: _libraryId,
        categoryId: _categoryId,
        format: _format,
        sellerType: _sellerType,
        condition: _condition,
        minPrice: _parsePrice(_minPriceController.text),
        maxPrice: _parsePrice(_maxPriceController.text),
      ),
    );
  }

  String? _validateMinPrice(String? raw) {
    final String? basic = _validatePrice(raw);
    if (basic != null) return basic;
    final double? min = _parsePrice(raw);
    final double? max = _parsePrice(_maxPriceController.text);
    if (min != null && max != null && min > max) {
      return 'books_catalog.filter.min_exceeds_max'.tr();
    }
    return null;
  }

  String? _validateMaxPrice(String? raw) {
    final String? basic = _validatePrice(raw);
    if (basic != null) return basic;
    final double? min = _parsePrice(_minPriceController.text);
    final double? max = _parsePrice(raw);
    if (min != null && max != null && max < min) {
      return 'books_catalog.filter.max_below_min'.tr();
    }
    return null;
  }

  String? _validatePrice(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final double? value = _parsePrice(raw);
    if (value == null) return 'books_catalog.filter.invalid_price'.tr();
    if (value < 0) return 'books_catalog.filter.non_negative_price'.tr();
    return null;
  }

  static double? _parsePrice(String? raw) {
    final String value = raw?.trim() ?? '';
    return value.isEmpty ? null : double.tryParse(value);
  }

  static String _displayPrice(double? price) {
    if (price == null) return '';
    return price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toString();
  }

  static String _conditionLabel(BookCondition value) => switch (value) {
        BookCondition.newBook => 'books_catalog.filter.conditions.new'.tr(),
        BookCondition.likeNew =>
          'books_catalog.filter.conditions.like_new'.tr(),
        BookCondition.good => 'books_catalog.filter.conditions.good'.tr(),
        BookCondition.acceptable =>
          'books_catalog.filter.conditions.acceptable'.tr(),
      };

  static String _formatLabel(ListingFormat value) => switch (value) {
        ListingFormat.digital =>
          'books_catalog.filter.listing_formats.digital'.tr(),
        ListingFormat.physical =>
          'books_catalog.filter.listing_formats.physical'.tr(),
      };

  static String _sellerLabel(SellerType value) => switch (value) {
        SellerType.library => 'books_catalog.filter.sellers.library'.tr(),
        SellerType.user => 'books_catalog.filter.sellers.user'.tr(),
      };
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: context.appTextSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DropdownOption<T> {
  const _DropdownOption({required this.value, required this.label});
  final T value;
  final String label;
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final T? value;
  final String hint;
  final List<_DropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Color border =
        context.isDark ? AppColors.primary700 : AppColors.primary200;
    return Container(
      height: 56,
      padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: context.appTextSecondary.withValues(alpha: 0.65),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary500,
          ),
          items: options
              .map(
                (_DropdownOption<T> option) => DropdownMenuItem<T>(
                  value: option.value,
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ChoiceWrap<T> extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
  });

  final List<T> values;
  final T? selected;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((T value) {
        final bool isSelected = selected == value;
        return ChoiceChip(
          key: ValueKey<String>('books_filter_${value.toString()}'),
          label: Text(labelBuilder(value)),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onChanged(isSelected ? null : value),
          backgroundColor: Colors.transparent,
          selectedColor: AppColors.primary50,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary600
                : context.isDark
                    ? AppColors.primary700
                    : AppColors.primary200,
          ),
          shape: const StadiumBorder(),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: context.isDark ? AppColors.primary300 : AppColors.primary600,
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({
    required this.label,
    required this.controller,
    required this.validator,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _FilterLabel(label),
        TextFormField(
          controller: controller,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: ui.TextDirection.ltr,
          inputFormatters: <TextInputFormatter>[
            _PriceInputFormatter(),
          ],
          decoration: InputDecoration(
            hintText: 'books_catalog.filter.enter_number'.tr(),
            errorMaxLines: 2,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: context.isDark
                    ? AppColors.primary700
                    : AppColors.primary200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary600,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!text.codeUnits.every(
      (int code) => (code >= 48 && code <= 57) || code == 46,
    )) {
      return oldValue;
    }
    final List<String> parts = text.split('.');
    if (parts.length > 2 || (parts.length == 2 && parts[1].length > 2)) {
      return oldValue;
    }
    return newValue;
  }
}

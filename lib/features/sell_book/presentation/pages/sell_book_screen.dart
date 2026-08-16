import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../libraries/domain/entities/library_book_entity.dart';
import '../../../libraries/domain/entities/library_entity.dart';
import '../../../libraries/domain/repositories/libraries_repository.dart';
import '../../../libraries/domain/repositories/library_details_repository.dart';
import '../../../libraries/domain/use_cases/get_libraries_use_case.dart';
import '../../../libraries/domain/use_cases/get_library_books_use_case.dart';
import '../../domain/entities/sell_book.dart';
import '../../domain/use_cases/submit_sell_book_use_case.dart';

class SellBookScreen extends StatefulWidget {
  const SellBookScreen({super.key});

  @override
  State<SellBookScreen> createState() => _SellBookScreenState();
}

class _SellBookScreenState extends State<SellBookScreen> {
  static const int _maxImageBytes = 5 * 1024 * 1024;
  final TextEditingController _isbn = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  SellBookMethod _method = SellBookMethod.isbn;
  SellBookCondition _condition = SellBookCondition.used;
  XFile? _image;
  List<LibraryEntity> _libraries = const <LibraryEntity>[];
  List<LibraryBookEntity> _books = const <LibraryBookEntity>[];
  LibraryEntity? _library;
  LibraryBookEntity? _book;
  String _query = '';
  String? _error;
  String? _priceError;
  String? _imageError;
  bool _loadingLibraries = false;
  bool _loadingBooks = false;
  bool _submitting = false;

  @override
  void dispose() {
    _isbn.dispose();
    _price.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _changeMethod(SellBookMethod method) async {
    setState(() {
      _method = method;
      _error = null;
    });
    if (method == SellBookMethod.library && _libraries.isEmpty) {
      await _loadLibraries();
    }
  }

  Future<void> _loadLibraries() async {
    setState(() => _loadingLibraries = true);
    final Result<LibrariesPage> result = await sl<GetLibrariesUseCase>()(
      const GetLibrariesParams(
        searchTerm: '',
        pageNumber: 1,
        pageSize: 100,
      ),
    );
    if (!mounted) return;
    switch (result) {
      case Success<LibrariesPage>(value: final LibrariesPage page):
        setState(() {
          _libraries = page.items;
          _loadingLibraries = false;
        });
      case ResultFailure<LibrariesPage>(message: final String message):
        setState(() {
          _error = message;
          _loadingLibraries = false;
        });
    }
  }

  Future<void> _selectLibrary(String? id) async {
    if (id == null) return;
    final LibraryEntity selected = _libraries.firstWhere(
      (LibraryEntity item) => item.id == id,
    );
    setState(() {
      _library = selected;
      _book = null;
      _books = const <LibraryBookEntity>[];
      _query = '';
      _search.clear();
      _loadingBooks = true;
      _error = null;
    });
    final Result<LibraryBooksPage> result = await sl<GetLibraryBooksUseCase>()(
      GetLibraryBooksParams(
        libraryId: selected.id,
        pageNumber: 1,
        pageSize: 100,
        searchTerm: '',
        sortBy: '',
        sortDescending: false,
      ),
    );
    if (!mounted || _library?.id != selected.id) return;
    switch (result) {
      case Success<LibraryBooksPage>(value: final LibraryBooksPage page):
        setState(() {
          _books = page.items;
          _loadingBooks = false;
        });
      case ResultFailure<LibraryBooksPage>(message: final String message):
        setState(() {
          _error = message;
          _loadingBooks = false;
        });
    }
  }

  List<LibraryBookEntity> get _filteredBooks {
    final String value = _query.trim().toLowerCase();
    if (value.isEmpty) return _books;
    return _books.where((LibraryBookEntity book) {
      return book.title.toLowerCase().contains(value) ||
          book.author.toLowerCase().contains(value) ||
          book.isbn.toLowerCase().contains(value);
    }).toList(growable: false);
  }

  Future<void> _pick(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 88,
    );
    if (picked == null) return;
    if (await picked.length() > _maxImageBytes) {
      if (mounted) {
        setState(() => _imageError = 'The image must be smaller than 5 MB.');
      }
      return;
    }
    if (mounted) {
      setState(() {
        _image = picked;
        _imageError = null;
      });
    }
  }

  Future<void> _submit() async {
    final double? price = double.tryParse(_price.text.trim());
    final String isbn =
        _method == SellBookMethod.library ? _book?.isbn ?? '' : _isbn.text;
    setState(() {
      _priceError =
          price == null || price <= 0 ? 'Price must be greater than 0.' : null;
      _imageError = _image == null ? 'Upload one image of the book.' : null;
      _error = switch (_method) {
        SellBookMethod.library when _library == null => 'Choose a library.',
        SellBookMethod.library when _book == null => 'Choose a book.',
        _ when isbn.trim().isEmpty => 'Book ISBN is required.',
        _ => null,
      };
    });
    if (_priceError != null || _imageError != null || _error != null) return;

    final XFile image = _image!;
    setState(() => _submitting = true);
    final Result<String> result = await sl<SubmitSellBookUseCase>()(
      SellBookDraft(
        method: _method,
        isbn: isbn,
        libraryBookId: _book?.bookId,
        title: _book?.title,
        price: price!,
        condition: _condition,
        images: <SellBookImage>[
          SellBookImage(
            path: image.path,
            name: image.name,
            bytes: await image.length(),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    switch (result) {
      case Success<String>():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book published successfully.')),
        );
        Navigator.of(context).maybePop();
      case ResultFailure<String>(message: final String message):
        setState(() => _error = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appCard,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _header(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                children: <Widget>[
                  SellBookMethodTabBar(
                    value: _method,
                    onChanged: _changeMethod,
                  ),
                  const SizedBox(height: 16),
                  if (_method == SellBookMethod.library)
                    _libraryFields()
                  else
                    _field(
                      'Book ISBN',
                      AppTextField(
                        controller: _isbn,
                        hintText: 'Enter The Book ISBN',
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() => _error = null),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _preview(_method == SellBookMethod.library ? _book : null),
                  const SizedBox(height: 16),
                  _field(
                    'My Price',
                    AppTextField(
                      controller: _price,
                      hintText: 'Enter Your book price',
                      textInputAction: TextInputAction.next,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() => _priceError = null),
                    ),
                  ),
                  if (_priceError != null) _errorText(_priceError!),
                  const SizedBox(height: 16),
                  _conditionField(),
                  const SizedBox(height: 16),
                  _imageField(),
                  if (_error != null) _errorText(_error!),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppColors.primary600,
                    ),
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publish'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: Navigator.of(context).maybePop,
              icon: Icon(
                context.isRTL ? Icons.arrow_forward : Icons.arrow_back,
                color: context.appTextPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Publish Book',
              style: AppTextStyles.h4.copyWith(color: context.appTextPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _libraryFields() {
    return Column(
      children: <Widget>[
        _field(
          'Library of book',
          _loadingLibraries
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  initialValue: _library?.id,
                  isExpanded: true,
                  decoration: _dropdownDecoration('Choose the Library'),
                  items: _libraries.map((LibraryEntity library) {
                    return DropdownMenuItem<String>(
                      value: library.id,
                      child: Text(
                        library.libraryName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(growable: false),
                  onChanged: _selectLibrary,
                ),
        ),
        const SizedBox(height: 16),
        _field(
          'Select Book',
          AppTextField(
            controller: _search,
            hintText: 'Search in the book name or ISBN',
            textInputAction: TextInputAction.search,
            onChanged: (String value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: 8),
        if (_loadingBooks)
          const Center(child: CircularProgressIndicator())
        else if (_library != null)
          DropdownButtonFormField<String>(
            key: ValueKey<String>(
              '${_library!.id}:${_book?.listingId ?? ''}',
            ),
            initialValue: _book?.listingId,
            isExpanded: true,
            decoration: _dropdownDecoration('Choose the Book'),
            items: _filteredBooks.map((LibraryBookEntity book) {
              return DropdownMenuItem<String>(
                value: book.listingId,
                child: Text(book.title, overflow: TextOverflow.ellipsis),
              );
            }).toList(growable: false),
            onChanged: (String? id) {
              if (id == null) return;
              setState(() {
                _book = _books.firstWhere(
                  (LibraryBookEntity item) => item.listingId == id,
                );
                _error = null;
              });
            },
          ),
      ],
    );
  }

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: context.appCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.appBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: context.appBorder),
      ),
    );
  }

  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: context.appTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _preview(LibraryBookEntity? book) {
    return _field(
      'Book Preview',
      Container(
        height: 192,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDark ? context.appSurface : AppColors.primary50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: book == null
            ? const _PreviewSkeleton()
            : Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverImageUrl,
                      width: 120,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 160,
                        color: AppColors.primary200,
                        child: const Icon(Icons.menu_book_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${book.title}\n'
                      'Language: ${book.language}\n'
                      'Writer: ${book.author}\n'
                      'ISBN: ${book.isbn}',
                      maxLines: 7,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _conditionField() {
    const Map<SellBookCondition, String> labels = <SellBookCondition, String>{
      SellBookCondition.newBook: 'New',
      SellBookCondition.used: 'Used',
      SellBookCondition.refurbished: 'Refactored',
    };
    return _field(
      'Status of Book',
      Wrap(
        spacing: 8,
        children: labels.entries.map((entry) {
          final bool selected = entry.key == _condition;
          return ChoiceChip(
            label: Text(entry.value),
            selected: selected,
            onSelected: (_) => setState(() => _condition = entry.key),
            selectedColor: AppColors.primary500,
            labelStyle: TextStyle(
              color: selected ? AppColors.primary50 : AppColors.primary600,
            ),
            side: const BorderSide(color: AppColors.primary200),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _imageField() {
    return _field(
      'Upload',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Upload one image of the actual book, smaller than 5 MB.',
            style: AppTextStyles.bodySmall.copyWith(
              color: context.appTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.upload_outlined),
            label: Text(
              _image == null ? 'Upload image from gallery' : 'Replace image',
            ),
          ),
          TextButton.icon(
            onPressed: () => _pick(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Take a photo'),
          ),
          if (_imageError != null) _errorText(_imageError!),
          if (_image != null)
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_image!.path),
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                  ),
                ),
                PositionedDirectional(
                  end: 0,
                  top: 0,
                  child: IconButton.filled(
                    onPressed: () => setState(() => _image = null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _errorText(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(color: AppColors.error500),
      ),
    );
  }
}

class SellBookMethodTabBar extends StatelessWidget {
  const SellBookMethodTabBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final SellBookMethod value;
  final ValueChanged<SellBookMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.isDark ? context.appSurface : AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: SellBookMethod.values.map((SellBookMethod method) {
          final bool selected = method == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(method),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary900 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  switch (method) {
                    SellBookMethod.isbn => 'International',
                    SellBookMethod.library => 'Library',
                    SellBookMethod.own => 'My own',
                  },
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: selected ? Colors.white : context.appTextPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 104,
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.primary200,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.generate(
              5,
              (int index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  height: index < 2 ? 24 : 16,
                  width: index == 0 ? 140 : double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

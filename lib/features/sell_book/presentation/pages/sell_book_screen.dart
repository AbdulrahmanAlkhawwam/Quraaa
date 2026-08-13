import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../shared/shared.dart';

enum SellMethod { isbn, library, own }

/// Temporary interactive sell-book form; its ISBN lookup is replaced by API later.
class SellBookScreen extends StatefulWidget {
  const SellBookScreen({super.key});

  @override
  State<SellBookScreen> createState() => _SellBookScreenState();
}

class _SellBookScreenState extends State<SellBookScreen> {
  final _isbn = TextEditingController();
  final _price = TextEditingController();
  final _picker = ImagePicker();
  SellMethod _method = SellMethod.isbn;
  bool _loading = false;
  bool _found = false;
  String? _priceError;
  String? _imageError;
  final List<XFile> _images = <XFile>[];

  @override
  void dispose() {
    _isbn.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _lookup(String value) async {
    final normalized = value.replaceAll(RegExp(r'[^0-9Xx]'), '');
    if (normalized.length < 10) return;
    setState(() {
      _loading = true;
      _found = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _found = normalized == '9780306406157';
    });
  }

  Future<void> _pick(ImageSource source) async {
    final remaining = 3 - _images.length;
    if (remaining <= 0) return;
    final picked = source == ImageSource.camera
        ? <XFile>[?await _picker.pickImage(source: source)]
        : await _picker.pickMultiImage();
    final candidates = picked.take(remaining).toList();
    final valid = <XFile>[];
    for (final image in candidates) {
      if (await image.length() < 15 * 1024 * 1024) valid.add(image);
    }
    if (!mounted) return;
    setState(() {
      _images.addAll(valid);
      _imageError =
          valid.length != candidates.length || picked.length > remaining
          ? 'Use up to 3 images, each smaller than 15 MB.'
          : null;
    });
  }

  void _submit(bool draft) {
    final price = double.tryParse(_price.text);
    setState(
      () => _priceError = price == null || price <= 0
          ? 'Price must be greater than 0.'
          : null,
    );
    if (_priceError != null || (_method == SellMethod.isbn && !_found)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(draft ? 'Draft saved.' : 'Book published.')),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: Navigator.of(context).maybePop,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary900,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Publish Book',
                    style: AppTextStyles.h4.copyWith(
                      color: AppColors.primary900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: <Widget>[
                SellBookMethodTabBar(
                  value: _method,
                  onChanged: (value) => setState(() {
                    _method = value;
                    _found = false;
                  }),
                ),
                const SizedBox(height: 16),
                if (_method == SellMethod.isbn) ...<Widget>[
                  _field(
                    'Book ISBN',
                    AppTextField(
                      controller: _isbn,
                      hintText: 'Enter The Book ISBN',
                      textInputAction: TextInputAction.next,
                      onChanged: _lookup,
                      suffixIcon: _loading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _preview(),
                ],
                if (_method != SellMethod.isbn) ...<Widget>[
                  _field(
                    _method == SellMethod.library
                        ? 'Library book'
                        : 'Book title',
                    AppTextField(
                      controller: _isbn,
                      hintText: _method == SellMethod.library
                          ? 'Search your library'
                          : 'Enter book title',
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 16),
                _field(
                  'My Price',
                  AppTextField(
                    controller: _price,
                    hintText: 'Enter Your book price',
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() => _priceError = null),
                  ),
                ),
                if (_priceError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _priceError!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error500,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                _condition(),
                const SizedBox(height: 16),
                _imagesField(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _submit(false),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primary600,
                  ),
                  child: Text(
                    'Publish',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _submit(true),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primary200),
                  ),
                  child: Text(
                    'Save As Draft',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.primary900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary900),
      ),
      const SizedBox(height: 8),
      child,
    ],
  );

  Widget _preview() => _field(
    'Book Preview',
    Container(
      height: 192,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _found
          ? Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/books/global_english_10.png',
                    width: 120,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Used',
                          style: TextStyle(fontSize: 8, color: Colors.white),
                        ),
                      ),
                      Text(
                        'Global English Coursebook 10',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.primary900,
                        ),
                      ),
                      const Text(
                        'Language: English\nPublisher: Cambridge University\nWriter: Tim Carter & Katia Carter\nversion: 10th for 2025',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const _PreviewSkeleton(),
    ),
  );

  Widget _condition() => _field(
    'Status of Book',
    Wrap(
      spacing: 8,
      children: <String>['New', 'Used', 'Refactored']
          .map(
            (label) => ChoiceChip(
              label: Text(label),
              selected: label == 'Used',
              selectedColor: AppColors.primary500,
              labelStyle: TextStyle(
                color: label == 'Used'
                    ? AppColors.primary50
                    : AppColors.primary600,
              ),
              side: const BorderSide(color: AppColors.primary200),
            ),
          )
          .toList(),
    ),
  );

  Widget _imagesField() => _field(
    'Upload',
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Add up to 3 images. Each image must be less than 15 MB.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary900),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _pick(ImageSource.gallery),
          icon: const Icon(Icons.upload_outlined),
          label: const Text('Upload image from gallery'),
        ),
        TextButton.icon(
          onPressed: () => _pick(ImageSource.camera),
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Take a photo'),
        ),
        if (_imageError != null)
          Text(
            _imageError!,
            style: AppTextStyles.caption.copyWith(color: AppColors.error500),
          ),
        if (_images.isNotEmpty)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(
                children: <Widget>[
                  Image.file(
                    File(_images[i].path),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                  IconButton(
                    onPressed: () => setState(() => _images.removeAt(i)),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class SellBookMethodTabBar extends StatelessWidget {
  const SellBookMethodTabBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final SellMethod value;
  final ValueChanged<SellMethod> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 40,
    decoration: BoxDecoration(
      color: AppColors.primary50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: SellMethod.values.map((method) {
        final selected = method == value;
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
                  SellMethod.isbn => 'International',
                  SellMethod.library => 'Library',
                  SellMethod.own => 'My own',
                },
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.primary900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) => Row(
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
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                height: i < 2 ? 24 : 16,
                width: i == 0 ? 140 : double.infinity,
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

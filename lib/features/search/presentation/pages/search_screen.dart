import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../books/books.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GetBooksUseCase _getBooks = sl<GetBooksUseCase>();
  final List<String> _recent = <String>[];
  Timer? _debounce;
  List<Book> _results = const <Book>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _changed(String value) {
    setState(() {});
    _debounce?.cancel();
    final String query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const <Book>[];
        _loading = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<Book> books = await _getBooks(query: query);
      if (!mounted || query != _controller.text.trim()) return;
      setState(() {
        _results = books;
        _loading = false;
        if (!_recent.contains(query)) _recent.insert(0, query);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.spacing16),
              child: Row(
                children: <Widget>[
                  IconButton.filledTonal(
                    onPressed: context.back,
                    icon: HugeIcon(
                      icon: context.isRTL
                          ? HugeIcons.strokeRoundedArrowRight01
                          : HugeIcons.strokeRoundedArrowLeft01,
                      color: context.appTextPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: _changed,
                      decoration: InputDecoration(
                        hintText: LocalizationConstants.searchHintKey.tr(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _controller.clear();
                                  _changed('');
                                },
                                icon: const Icon(Icons.close),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _content() {
    if (_controller.text.trim().isEmpty) {
      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
        children: <Widget>[
          Text(
            LocalizationConstants.searchTrendingKey.tr(),
            style: AppTextStyles.h4.copyWith(color: context.appTextPrimary),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <String>[
              LocalizationConstants.onboardingInterestHistoryKey,
              LocalizationConstants.searchMathematicalKey,
              LocalizationConstants.onboardingInterestScienceKey,
              LocalizationConstants.searchPhilosophyKey,
              LocalizationConstants.onboardingInterestLiteratureKey,
            ].map((String key) {
              final String label = key.tr();
              return ActionChip(
                label: Text(label),
                onPressed: () {
                  _controller.text = label;
                  _changed(label);
                },
              );
            }).toList(growable: false),
          ),
          if (_recent.isNotEmpty) ...<Widget>[
            const SizedBox(height: 28),
            Text(
              LocalizationConstants.searchRecentKey.tr(),
              style: AppTextStyles.h4.copyWith(color: context.appTextPrimary),
            ),
            ..._recent.take(5).map(
                  (String query) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(query),
                    onTap: () {
                      _controller.text = query;
                      _changed(query);
                    },
                  ),
                ),
          ],
        ],
      );
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: TextButton.icon(
          onPressed: () => _search(_controller.text.trim()),
          icon: const Icon(Icons.refresh),
          label: Text(LocalizationConstants.commonRetryKey.tr()),
        ),
      );
    }
    if (_results.isEmpty) {
      return Center(child: Text('books_catalog.empty'.tr()));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int index) {
        final Book book = _results[index];
        return ListTile(
          tileColor: context.appCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.radius16),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 46,
              height: 58,
              child: book.displayCover.isEmpty
                  ? const ColoredBox(
                      color: AppColors.primary100,
                      child: Icon(Icons.menu_book_outlined),
                    )
                  : Image.network(
                      book.displayCover,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.book),
                    ),
            ),
          ),
          title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(book.author, maxLines: 1),
          trailing: Icon(
            context.isRTL ? Icons.chevron_left : Icons.chevron_right,
          ),
          onTap: () => context.pushTo(
            RouteNames.bookDetailsPath(book.listingId, book.id),
          ),
        );
      },
    );
  }
}

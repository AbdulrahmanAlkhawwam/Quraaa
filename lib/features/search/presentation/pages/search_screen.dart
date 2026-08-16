import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../../books/books.dart';
import '../../../libraries/libraries.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GetBooksUseCase _getBooks = sl<GetBooksUseCase>();
  final AuthorsRepository _authorsRepository = sl<AuthorsRepository>();
  final LibrariesRepository _librariesRepository = sl<LibrariesRepository>();
  final List<String> _recent = <String>[];
  Timer? _debounce;
  List<Book> _books = const <Book>[];
  List<AuthorSearchResult> _authors = const <AuthorSearchResult>[];
  List<LibrarySearchEntity> _libraries = const <LibrarySearchEntity>[];
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
        _books = const <Book>[];
        _authors = const <AuthorSearchResult>[];
        _libraries = const <LibrarySearchEntity>[];
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
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _getBooks(query: query),
        _authorsRepository.searchAuthors(query),
        _librariesRepository.searchLibraries(
          searchTerm: query,
          pageNumber: 1,
          pageSize: 10,
        ),
      ]);
      if (!mounted || query != _controller.text.trim()) return;
      final List<Book> books = results[0] as List<Book>;
      List<AuthorSearchResult> authors = const <AuthorSearchResult>[];
      List<LibrarySearchEntity> libraries = const <LibrarySearchEntity>[];
      String? error;
      (results[1] as Result<AuthorSearchPage>).fold(
        (failure) => error = failure.message,
        (page) => authors = page.items,
      );
      (results[2] as Result<LibrarySearchPage>).fold(
        (failure) => error ??= failure.message,
        (page) => libraries = page.items,
      );
      setState(() {
        _books = books;
        _authors = authors;
        _libraries = libraries;
        _loading = false;
        _error = books.isEmpty && authors.isEmpty && libraries.isEmpty
            ? error
            : null;
        if (!_recent.contains(query)) _recent.insert(0, query);
      });
    } catch (error) {
      if (!mounted || query != _controller.text.trim()) return;
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
    if (_controller.text.trim().isEmpty) return _initialContent();
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
    if (_books.isEmpty && _authors.isEmpty && _libraries.isEmpty) {
      return Center(child: Text('books_catalog.empty'.tr()));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
      children: <Widget>[
        if (_authors.isNotEmpty) ...<Widget>[
          _SectionTitle('search.authors'.tr()),
          ..._authors.map(_authorTile),
          const SizedBox(height: 18),
        ],
        if (_libraries.isNotEmpty) ...<Widget>[
          _SectionTitle('search.libraries'.tr()),
          ..._libraries.map(_libraryTile),
          const SizedBox(height: 18),
        ],
        if (_books.isNotEmpty) ...<Widget>[
          _SectionTitle('search.books'.tr()),
          ..._books.map(_bookTile),
        ],
      ],
    );
  }

  Widget _initialContent() {
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

  Widget _authorTile(AuthorSearchResult author) {
    return _ResultTile(
      imageUrl: author.photoUrl ?? '',
      fallbackIcon: Icons.person_outline,
      title: author.name,
      subtitle: '${author.totalBooksCount} ${'search.books'.tr()}',
      onTap: () => context.pushTo(RouteNames.authorDetailsPath(author.id)),
    );
  }

  Widget _libraryTile(LibrarySearchEntity library) {
    return _ResultTile(
      imageUrl: library.logoUrl ?? '',
      fallbackIcon: Icons.store_outlined,
      title: library.name,
      subtitle: library.location ?? '',
      onTap: () => context.pushTo(
        '/libraries/${library.id}',
        extra: LibraryEntity(
          id: library.id,
          libraryName: library.name,
          location: library.location ?? '',
          libraryImage: library.logoUrl ?? '',
          headerImage: '',
          email: '',
        ),
      ),
    );
  }

  Widget _bookTile(Book book) {
    return _ResultTile(
      imageUrl: book.displayCover,
      fallbackIcon: Icons.menu_book_outlined,
      title: book.title,
      subtitle: book.author,
      onTap: () => context.pushTo(
        RouteNames.bookDetailsPath(book.listingId, book.id),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(color: context.appTextPrimary),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String imageUrl;
  final IconData fallbackIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: context.appCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius16),
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 48,
            height: 56,
            child: imageUrl.isEmpty
                ? ColoredBox(
                    color: AppColors.primary100,
                    child: Icon(fallbackIcon),
                  )
                : AppImage(
                    imageUrl,
                    width: 48,
                    height: 56,
                    fit: BoxFit.cover,
                    errorWidget: Icon(fallbackIcon),
                  ),
          ),
        ),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(
          context.isRTL ? Icons.chevron_left : Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}

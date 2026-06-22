import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/shared.dart';

/// Search screen with expanded search UI.
/// This screen is shown after the animated transition from the home search widget.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _recentSearches = <String>[];
  final List<String> _trendingSearches = <String>[
    'History',
    'Mathematical',
    'Science',
    'Philosophy',
    'Literature',
    'Art',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when the screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Animated Search Bar (at the top)
            _buildSearchBar(),
            const SizedBox(height: AppSpacing.spacing24),
            // Search content that animates down
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (
                  Widget child,
                  Animation<double> animation,
                ) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _searchController.text.isEmpty
                    ? _buildDefaultContent()
                    : _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacing16,
        vertical: AppSpacing.spacing12,
      ),
      child: Row(
        children: <Widget>[
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.spacing12),
          // Search input field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.radius12),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                onChanged: (_) => setState(() {}),
                textAlignVertical: TextAlignVertical.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search books, authors...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(AppSpacing.spacing12),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedSearch01,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(AppSpacing.spacing12),
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedCancel01,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      key: const ValueKey<String>('default'),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Trending searches
          Text(
            'Trending',
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Wrap(
            spacing: AppSpacing.spacing8,
            runSpacing: AppSpacing.spacing8,
            children: _trendingSearches.map((String search) {
              return _buildChip(search);
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.spacing32),
          // Recent searches (if any)
          if (_recentSearches.isNotEmpty) ...<Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Recent',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: Text(
                    'Clear',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing16),
            ..._recentSearches.map((String search) {
              return _buildRecentItem(search);
            }),
          ],
          const SizedBox(height: AppSpacing.spacing32),
          // Browse categories hint
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.spacing20),
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.radius16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBookOpen01,
                  color: AppColors.primary600,
                  size: 28,
                ),
                const SizedBox(height: AppSpacing.spacing12),
                Text(
                  'Browse Categories',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Discover books by exploring different categories and genres.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Center(
      key: const ValueKey<String>('results'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          HugeIcon(
            icon: HugeIcons.strokeRoundedSearch01,
            color: AppColors.primary200,
            size: 64,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            'Searching for "${_searchController.text}"...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            'Results will appear here soon.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing8,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.radius24),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
        child: Row(
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedClock01,
              color: AppColors.textTertiary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Text(
                search,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _recentSearches.remove(search)),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCancel01,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

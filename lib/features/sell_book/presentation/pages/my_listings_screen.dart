import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/my_listing.dart';
import '../../domain/repositories/sell_book_repository.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late Future<Result<List<MyListing>>> _request;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _request = sl<SellBookRepository>().getMyListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            context.isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          ),
        ),
        title: Text('listings.title'.tr()),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await context.push(RouteNames.sellBook);
              if (mounted) setState(_reload);
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: FutureBuilder<Result<List<MyListing>>>(
        future: _request,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          String? error;
          final List<MyListing> listings = snapshot.data!.fold(
            (failure) {
              error = failure.message;
              return const <MyListing>[];
            },
            (value) => value,
          );
          if (error != null) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(_reload),
                icon: const Icon(Icons.refresh),
                label: Text(error!),
              ),
            );
          }
          if (listings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.sell_outlined, size: 64),
                  const SizedBox(height: 12),
                  Text('listings.empty'.tr()),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.push(RouteNames.sellBook),
                    child: Text('listings.add'.tr()),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(_reload);
              await _request;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: listings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) {
                return _ListingCard(listing: listings[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final MyListing listing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appSubtleSurface,
      borderRadius: BorderRadius.circular(AppRadius.radius16),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.radius16),
        onTap: () => context.push(
          RouteNames.bookDetailsPath(listing.listingId, listing.bookId),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 92,
                  height: 124,
                  child: listing.coverImageUrl.isEmpty
                      ? const ColoredBox(
                          color: AppColors.primary100,
                          child: Icon(Icons.menu_book),
                        )
                      : Image.network(
                          listing.coverImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.book),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: context.appTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(listing.author),
                    Text('${'orders.price'.tr()} : ${listing.price}'),
                    Text('${'listings.stock'.tr()} : ${listing.stock}'),
                    Text('${'orders.book_status'.tr()} : ${listing.condition}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

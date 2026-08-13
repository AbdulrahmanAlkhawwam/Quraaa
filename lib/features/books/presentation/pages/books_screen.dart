import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/book.dart';
import '../bloc/books_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/books_search_bar.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => sl<BooksBloc>()..add(const BooksRequested()),
    child: const _BooksView(),
  );
}

class _BooksView extends StatelessWidget {
  const _BooksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: context.appBackground,
      bottomNavigationBar: HomeBottomNav(
        currentIndex: 2,
        isGuest: false,
        onTap: (_, String route) {
          if (route != RouteNames.userBooks) {
            context.goTo(route);
          }
        },
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Hi, Abdulrahman',
                      style: TextStyle(
                        color: AppColors.primary900,
                        fontFamily: 'Thmanyah Serif Display',
                        fontSize: 22,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primary50,
                    child: Icon(
                      Icons.person_outline,
                      color: AppColors.primary900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: BooksSearchBar(
                onChanged: (String value) =>
                    context.read<BooksBloc>().add(BooksQueryChanged(value)),
                onFilterPressed: () => _showFilterSheet(context),
              ),
            ),
            const SizedBox(height: 8),
            const BooksFormatFilters(),
            Expanded(
              child: BlocBuilder<BooksBloc, BooksState>(
                builder: (_, BooksState state) {
                  if (state.status == BooksStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 128),
                    itemCount: state.books.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 24,
                          crossAxisSpacing: 24,
                          childAspectRatio: .74,
                        ),
                    itemBuilder: (_, int i) => BookCard(book: state.books[i]),
                  );
                },
              ),
            ),
            // PositionedDirectional(
            //   start: 0,
            //   end: 0,
            //   bottom: 0,
            //   child: HomeBottomNav(
            //     currentIndex: 2,
            //     isGuest: false,
            //     onTap: (_, String route) {
            //       if (route != RouteNames.userBooks) {
            //         context.goTo(route);
            //       }
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'Filter books',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          ...BookFormat.values.map(
            (BookFormat f) => ListTile(
              title: Text(_label(f)),
              onTap: () {
                context.read<BooksBloc>().add(BooksFilterChanged(f));
                Navigator.pop(sheetContext);
              },
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<BooksBloc>().add(const BooksFilterChanged(null));
              Navigator.pop(sheetContext);
            },
            child: const Text('Clear filter'),
          ),
        ],
      ),
    ),
  );
}

/// The format-filter row from Figma node 651:3796.
///
/// A scroll view with a Row keeps every chip at its intrinsic width while
/// providing a bounded cross axis. This avoids placing padding/button children
/// directly in a horizontal sliver with unconstrained layout.
class BooksFormatFilters extends StatelessWidget {
  const BooksFormatFilters({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 42,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: BookFormat.values
            .map(
              (BookFormat f) => Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: OutlinedButton(
                  onPressed: () =>
                      context.read<BooksBloc>().add(BooksFilterChanged(f)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary600,
                    side: const BorderSide(color: AppColors.primary200),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(_label(f)),
                ),
              ),
            )
            .toList(),
      ),
    ),
  );
}

String _label(BookFormat f) => switch (f) {
  BookFormat.audio => 'Sound Book',
  BookFormat.ebook => 'E-book',
  BookFormat.free => 'Free book',
  BookFormat.used => 'Used Book',
};

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/features/home/presentation/widgets/home_section_shimmer.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  testWidgets('renders three shimmer book placeholders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: HomeSectionShimmer())),
    );

    expect(
      find.byKey(const ValueKey<String>('home-books-shimmer')),
      findsOneWidget,
    );
    expect(find.byType(Shimmer), findsNWidgets(3));
  });
}

// // This is a basic Flutter widget test.
// //
// // To perform an interaction with a widget in your test, use the WidgetTester
// // utility in the flutter_test package. For example, you can send tap and scroll
// // gestures. You can also use WidgetTester to find child widgets in the widget
// // tree, read text, and verify that the values of widget properties are correct.
//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:quraaa/app/app.dart';
// import 'package:quraaa/core/localization/localization_service.dart';
//
// void main() {
//   TestWidgetsFlutterBinding.ensureInitialized();
//
//   setUpAll(() async {
//     await LocalizationService.ensureInitialized();
//   });
//
//   testWidgets('renders the localized login page', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       LocalizationService.wrap(
//         child: const QuraaaApp(),
//       ),
//     );
//     await tester.pump(const Duration(seconds: 1));
//     expect(find.text('Welcome back'), findsOneWidget);
//     expect(find.text('Sign in to continue'), findsOneWidget);
//   });
// }

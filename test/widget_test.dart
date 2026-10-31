import 'package:flutter_test/flutter_test.dart';

import 'package:jobtrack/main.dart';
import 'package:jobtrack/utils/constants.dart';

void main() {
  testWidgets('home screen renders the primary actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.exploreJobs), findsOneWidget);
    expect(find.text(AppStrings.getStarted), findsWidgets);
  });
}

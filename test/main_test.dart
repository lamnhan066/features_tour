import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = FeaturesTourController(
      'App',
      waitForFirstIndex: 2,
    );
    await tester.pumpWidget(
      App(tours: [
        FeaturesTour(
          index: 1,
          controller: controller,
          introduce: const Text('a.intro'),
          child: const Text('a'),
        ),
        FeaturesTour(
          index: 2,
          controller: controller,
          introduce: const Text('b.intro'),
          child: const Text('b'),
        ),
      ]),
    );
    await tester.pumpAndSettle();
    await Future.delayed(const Duration(seconds: 1));

    expect(find.text('a'), findsOneWidget);
    expect(find.text('b'), findsOneWidget);
    expect(find.text('a.intro'), findsNothing);
    expect(find.text('b.intro'), findsOneWidget);
  });
}

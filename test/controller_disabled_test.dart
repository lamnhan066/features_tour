import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/unfeatures_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

enum _TestStep { step1 }

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('start emits disabled when FeaturesTour.enabled is false', (
    tester,
  ) async {
    final controller = FeaturesTourController<_TestStep>('App');

    await tester.pumpWidget(
      MaterialApp(
        home: App(
          tours: [
            FeaturesTour(
              step: _TestStep.step1,
              controller: controller,
              enabled: false,
              introduce: const Text('intro'),
              child: const Text('child'),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    final states = <TourState>[];

    await tester.runAsync(() async {
      await controller.start(
        tester.element(find.byType(App)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (s) async {
          states.add(s);
        },
      );
    });

    expect(
      states,
      containsAllInOrder([isA<TourEmpty>(), isA<TourCompleted>()]),
    );
  });

  testWidgets('start emits disabled when wrapped by UnfeaturesTour', (
    tester,
  ) async {
    final controller = FeaturesTourController<_TestStep>('App2');

    await tester.pumpWidget(
      MaterialApp(
        home: UnfeaturesTour(
          child: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('intro'),
                child: const Text('child'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final states = <TourState>[];

    await tester.runAsync(() async {
      await controller.start(
        tester.element(find.byType(App)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (s) async {
          states.add(s);
        },
      );
    });

    expect(
      states,
      containsAllInOrder([isA<TourEmpty>(), isA<TourCompleted>()]),
    );
  });
}

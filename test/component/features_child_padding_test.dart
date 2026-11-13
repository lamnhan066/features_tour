import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/components/features_child.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _TourStep { keypad }

/// Four 50dp rows separated by 8dp gaps.
const double _targetHeight = 4 * 50.0 + 3 * 8.0;

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetPreDialog();
    FeaturesTour.setGlobalConfig(
      preDialogConfig: PreDialogConfig(enabled: false),
      childConfig: ChildConfig(enableAnimation: false),
      nextConfig: NextConfig(text: 'NEXT'),
      doneConfig: DoneConfig(text: 'DONE'),
      skipConfig: SkipConfig(text: 'SKIP'),
    );
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required FeaturesTourController<_TourStep> controller,
    required List<double> recordedPadding,
  }) async {
    // Mirrors an iPhone 17 Pro Max: the root MediaQuery carries the screen
    // padding, which an outer SafeArea consumes before the target is laid out.
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(440, 956)
      ..padding = const FakeViewPadding(top: 62, bottom: 34);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                const Expanded(child: SizedBox()),
                FeaturesTour<_TourStep>(
                  controller: controller,
                  step: _TourStep.keypad,
                  introduce: const Text('keypad intro'),
                  child: Builder(
                    builder: (context) {
                      recordedPadding.add(
                        MediaQuery.paddingOf(context).bottom,
                      );
                      return SafeArea(
                        child: Column(
                          key: const Key('target_rows'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 4; i++) ...[
                              if (i > 0) const SizedBox(height: 8),
                              const SizedBox(
                                height: 50,
                                width: double.infinity,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('overlay copy reuses the padding the target sees', (
    tester,
  ) async {
    final controller = FeaturesTourController<_TourStep>('padding_fix');
    final recordedPadding = <double>[];
    await pumpApp(
      tester,
      controller: controller,
      recordedPadding: recordedPadding,
    );

    unawaited(
      controller.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(FeaturesChild), findsOneWidget);

    // The overlay is placed at the measured target rect, so its copy must not
    // apply the screen padding again.
    final overlayCopy = find.descendant(
      of: find.byType(FeaturesChild),
      matching: find.byKey(const Key('target_rows')),
    );
    expect(overlayCopy, findsOneWidget);
    expect(tester.getSize(overlayCopy), const Size(440, _targetHeight));

    expect(recordedPadding, isNotEmpty);
    expect(recordedPadding.every((padding) => padding == 0), isTrue);

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
  });

  testWidgets('metrics changes re-capture the target padding', (tester) async {
    final controller = FeaturesTourController<_TourStep>('padding_fix_metrics');
    final recordedPadding = <double>[];
    await pumpApp(
      tester,
      controller: controller,
      recordedPadding: recordedPadding,
    );

    unawaited(
      controller.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);

    // Rotation / different device metrics while the tour is up.
    tester.view.padding = const FakeViewPadding(top: 100, bottom: 50);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.byType(FeaturesChild), findsOneWidget);
    expect(recordedPadding.every((padding) => padding == 0), isTrue);

    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();
  });
}

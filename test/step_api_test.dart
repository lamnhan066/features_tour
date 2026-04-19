import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _TestStep { drawer, drawerButton }

void main() {
  setUp(() {
    FeaturesTour.setTestingLogger(const LiteLogger(minLevel: LogLevel.debug));
    resetPreDialog();
    SharedPreferences.setMockInitialValues({});

    FeaturesTour.setGlobalConfig(
      preDialogConfig: PreDialogConfig(enabled: false),
      nextConfig: NextConfig(text: 'NEXT'),
      doneConfig: DoneConfig(text: 'DONE'),
      skipConfig: SkipConfig(text: 'SKIP'),
    );
  });

  testWidgets('supports enum step identity and caches by step name', (
    tester,
  ) async {
    final controller = FeaturesTourController<_TestStep>('App');
    final collectedStates = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawer,
                introduce: const Text('drawer intro'),
                child: const Text('drawer child'),
              ),
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawerButton,
                introduce: const Text('button intro'),
                child: const Text('button child'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));

    await tester.runAsync(() async {
      await controller.start(
        context,
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          collectedStates.add(state);

          if (state case TourIntroducing(
            index: final index,
            step: final step,
          )) {
            if (index == _TestStep.drawer.index.toDouble()) {
              expect(step, _TestStep.drawer);
              await tester.pump();
              await tester.pump();
              expect(find.text('drawer intro'), findsOneWidget);
              await tester.tap(find.text('NEXT'));
            } else if (index == _TestStep.drawerButton.index.toDouble()) {
              expect(step, _TestStep.drawerButton);
              await tester.pump();
              await tester.pump();
              expect(find.text('button intro'), findsOneWidget);
              await tester.tap(find.text('DONE'));
            }
          }
        },
      );
    });

    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('FeaturesTour_App_drawer'), isTrue);
    expect(prefs.getBool('FeaturesTour_App_drawerButton'), isTrue);
    expect(
      collectedStates.whereType<TourIntroducing>().map((s) => s.index),
      containsAllInOrder([
        _TestStep.drawer.index.toDouble(),
        _TestStep.drawerButton.index.toDouble(),
      ]),
    );
  });

  testWidgets('starts from firstStep when it is provided', (tester) async {
    final controller = FeaturesTourController<_TestStep>('App');
    final collectedStates = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawer,
                introduce: const Text('drawer intro'),
                child: const Text('drawer child'),
              ),
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawerButton,
                introduce: const Text('button intro'),
                child: const Text('button child'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));

    await tester.runAsync(() async {
      await controller.start(
        context,
        force: true,
        delay: Duration.zero,
        firstStep: _TestStep.drawerButton,
        onStateChanged: (state) async {
          collectedStates.add(state);

          if (state case TourIntroducing(
            index: final index,
            step: final step,
          )) {
            await tester.pump();
            await tester.pump();
            expect(index, _TestStep.drawerButton.index.toDouble());
            expect(step, _TestStep.drawerButton);
            expect(find.text('button intro'), findsOneWidget);
            expect(controller.skip(), isTrue);
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(
      collectedStates.whereType<TourIntroducing>().first.index,
      _TestStep.drawerButton.index.toDouble(),
    );
  });

  testWidgets('supports omitted firstStepTimeout', (tester) async {
    final controller = FeaturesTourController<_TestStep>('App');
    final collectedStates = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawer,
                introduce: const Text('drawer intro'),
                child: const Text('drawer child'),
              ),
              FeaturesTour(
                controller: controller,
                step: _TestStep.drawerButton,
                introduce: const Text('button intro'),
                child: const Text('button child'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));

    await tester.runAsync(() async {
      await controller.start(
        context,
        force: true,
        delay: Duration.zero,
        firstStep: _TestStep.drawerButton,
        onStateChanged: (state) async {
          collectedStates.add(state);

          if (state case TourIntroducing(
            index: final index,
            step: final step,
          )) {
            await tester.pump();
            await tester.pump();
            expect(index, _TestStep.drawerButton.index.toDouble());
            expect(step, _TestStep.drawerButton);
            expect(find.text('button intro'), findsOneWidget);
            expect(controller.skip(), isTrue);
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(
      collectedStates.whereType<TourIntroducing>().first.index,
      _TestStep.drawerButton.index.toDouble(),
    );
  });

  testWidgets(
    'firstStepTimeout falls back to firstIndex when firstStep not present',
    (tester) async {
      final controller = FeaturesTourController<_TestStep>('App');
      final collectedStates = <TourState>[];

      // Only register the `drawer` step in the widget tree. The provided
      // `firstStep` is `drawerButton` which is not present, so after the
      // `firstStepTimeout` the controller should fall back to `firstIndex`.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FeaturesTour(
                  controller: controller,
                  step: _TestStep.drawer,
                  introduce: const Text('drawer intro'),
                  child: const Text('drawer child'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          // Ask to start at a step that doesn't exist in the tree.
          firstStep: _TestStep.drawerButton,
          firstStepTimeout: const Duration(milliseconds: 5),
          // Fallback to this index when the firstStep times out.
          firstIndex: _TestStep.drawer.index.toDouble(),
          firstIndexTimeout: const Duration(milliseconds: 5),
          onStateChanged: (state) async {
            collectedStates.add(state);

            if (state case TourIntroducing(
              index: final index,
              step: final step,
            )) {
              await tester.pump();
              await tester.pump();
              // Ensure we fell back to the `drawer` index.
              expect(index, _TestStep.drawer.index.toDouble());
              expect(step, _TestStep.drawer);
              expect(find.text('drawer intro'), findsOneWidget);
              expect(controller.skip(), isTrue);
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(
        collectedStates.whereType<TourIntroducing>().first.index,
        _TestStep.drawer.index.toDouble(),
      );
    },
  );
}

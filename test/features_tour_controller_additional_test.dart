import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_steps.dart';

void main() {
  setUp(() {
    FeaturesTour.setTestingLogger(const LiteLogger(minLevel: LogLevel.debug));
    resetPreDialog();
    SharedPreferences.setMockInitialValues({});

    FeaturesTour.setGlobalConfig(
      preDialogConfig: PreDialogConfig(enabled: false),
      nextConfig: NextConfig(text: 'NEXT'),
      previousConfig: PreviousConfig(text: 'PREVIOUS'),
      skipConfig: SkipConfig(text: 'SKIP'),
      doneConfig: DoneConfig(text: 'DONE'),
    );
  });

  testWidgets('start returns TourNotMounted when context unmounted', (
    tester,
  ) async {
    final controller = FeaturesTourController<TestStep>('UnmountTest');
    final collected = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            controller: controller,
            index: 1,
            introduce: const Text('intro'),
            child: const Text('content'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    final context = tester.element(find.byType(Scaffold));

    // Unmount the widget tree so the context becomes unmounted.
    await tester.pumpWidget(Container());

    await tester.runAsync(() async {
      await controller.start(
        context,
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          collected.add(state);
        },
      );
    });

    await tester.pumpAndSettle();

    expect(collected, contains(isA<TourNotMounted>()));
  });

  testWidgets('firstIndex timeout is handled and tour completes', (
    tester,
  ) async {
    final controller = FeaturesTourController<TestStep>('TimeoutTest');
    final collected = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              FeaturesTour(
                controller: controller,
                index: 1,
                introduce: const Text('intro1'),
                child: const Text('a'),
              ),
              FeaturesTour(
                controller: controller,
                index: 2,
                introduce: const Text('intro2'),
                child: const Text('b'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await controller.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
        firstIndex: 999, // nonexistent index to force timeout
        firstIndexTimeout: const Duration(milliseconds: 50),
        onStateChanged: (state) async {
          collected.add(state);
          if (state is TourIntroducing) {
            // finish this step
            controller.done();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(collected, contains(isA<TourCompleted>()));
  });

  testWidgets('removeState marks preference and re-show after clearing pref', (
    tester,
  ) async {
    final controller = FeaturesTourController<TestStep>('PrefsTest');
    final collected = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            controller: controller,
            index: 1,
            introduce: const Text('intro-pref'),
            child: const Text('content'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Run once and complete the step so the preference is set.
    await tester.runAsync(() async {
      await controller.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          collected.add(state);
          if (state is TourIntroducing) {
            controller.done();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    // The preference key is internal; assert that a key containing the pageName exists.
    final key = prefs.getKeys().firstWhere(
      (k) => k.contains(controller.pageName),
    );
    expect(key, isNotNull);

    // Remove the pref to simulate re-adding the state, then start again.
    await prefs.remove(key);
    collected.clear();

    await tester.runAsync(() async {
      await controller.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          collected.add(state);
          if (state is TourIntroducing) {
            // stop quickly
            controller.skip();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(collected, contains(isA<TourIntroducing>()));
  });

  testWidgets('constructor debugLog true/false does not crash', (tester) async {
    final c1 = FeaturesTourController<TestStep>('Debug1', debugLog: true);
    final c2 = FeaturesTourController<TestStep>('Debug2', debugLog: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            controller: c1,
            index: 1,
            introduce: const Text('i1'),
            child: const Text('c'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Start a simple tour to ensure no exceptions are thrown.
    await tester.runAsync(() async {
      await c1.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          if (state is TourIntroducing) {
            c1.skip();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    // Also ensure second controller can be used without throwing.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            controller: c2,
            index: 1,
            introduce: const Text('i2'),
            child: const Text('c2'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await c2.start(
        tester.element(find.byType(Scaffold)),
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          if (state is TourIntroducing) {
            c2.skip();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();
  });
}

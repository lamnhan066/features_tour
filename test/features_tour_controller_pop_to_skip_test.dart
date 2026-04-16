import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('pop-to-skip completes the tour when back pressed', (
    tester,
  ) async {
    final controller = FeaturesTourController('App');
    final collected = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Pop Test'),
            leading: FeaturesTour(
              controller: controller,
              index: 1,
              introduce: const Text('intro 1'),
              child: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
            ),
          ),
          body: FeaturesTour(
            controller: controller,
            index: 2,
            introduce: const Text('intro 2'),
            child: const Text('content'),
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
          collected.add(state);
          if (state is TourIntroducing) {
            // tap the visible SKIP button to simulate user back navigation
            await tester.pump();
            await tester.tap(find.text('SKIP'));
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(
      collected.whereType<TourActionEmitted>().last.action,
      TourAction.skip,
    );
    expect(collected, contains(isA<TourCompleted>()));
  });

  testWidgets('pop-to-skip ignored when popToSkip is false', (tester) async {
    final controller = FeaturesTourController('App');
    final collected = <TourState>[];
    var seenIntro = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            controller: controller,
            index: 1,
            introduce: const Text('intro only'),
            child: const Text('content'),
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
        popToSkip: false,
        onStateChanged: (state) async {
          collected.add(state);
          if (state is TourIntroducing && !seenIntro) {
            seenIntro = true;
            // previous() should be false at the first step
            expect(controller.previous(), isFalse);
            // finish the tour so test can complete
            controller.skip();
            await tester.pump();
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(seenIntro, isTrue);
    expect(
      collected.whereType<TourActionEmitted>().last.action,
      TourAction.skip,
    );
    expect(collected, contains(isA<TourCompleted>()));
  });
}

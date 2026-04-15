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
    final controller = FeaturesTourController('App');
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
        onState: (state) async {
          collectedStates.add(state);

          if (state case TourIntroducing(index: final index)) {
            if (index == _TestStep.drawer.index.toDouble()) {
              await tester.pump();
              await tester.pump();
              expect(find.text('drawer intro'), findsOneWidget);
              await tester.tap(find.text('NEXT'));
            } else if (index == _TestStep.drawerButton.index.toDouble()) {
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
}

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/cover_dialog.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/features_tour.dart'
    show DismissAllTourStorage;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() {
  var collectedStates = <TourState>[];

  setUp(() {
    resetPredialog();
    SharedPreferences.setMockInitialValues({});
    collectedStates = [];

    // Reset the global state for predialogs between tests
    FeaturesTour.setGlobalConfig(
      predialogConfig: PredialogConfig(enabled: false),
      nextConfig: NextConfig(text: 'NEXT'),
      skipConfig: SkipConfig(text: 'SKIP'),
      doneConfig: DoneConfig(text: 'DONE'),
    );
  });

  group('Static Methods and Storage', () {
    testWidgets('FeaturesTour.removeAll marks all tours as shown',
        (tester) async {
      final controller1 = FeaturesTourController('Page1');
      final controller2 = FeaturesTourController('Page2');
      await tester.pumpWidget(MaterialApp(
        home: Column(
          children: [
            FeaturesTour(
              index: 1,
              controller: controller1,
              introduce: const Text('p1.i1'),
              child: const Text('p1.c1'),
            ),
            FeaturesTour(
              index: 1,
              controller: controller2,
              introduce: const Text('p2.i1'),
              child: const Text('p2.c1'),
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      // At this point, controllers are registered and have states.
      await FeaturesTour.removeAll();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('FeaturesTour_Page1_1.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_Page2_1.0'), isTrue);
    });

    testWidgets('DismissAllTourStorage saves and retrieves dismissal state',
        (tester) async {
      // Init by calling it once.
      await DismissAllTourStorage.getDismissAllTours();

      var dismissed = await DismissAllTourStorage.getDismissAllTours();
      expect(dismissed, isFalse);

      await DismissAllTourStorage.setDismissAllTours(true);
      dismissed = await DismissAllTourStorage.getDismissAllTours();
      expect(dismissed, isTrue);

      await DismissAllTourStorage.setDismissAllTours(false);
      dismissed = await DismissAllTourStorage.getDismissAllTours();
      expect(dismissed, isFalse);
    });
  });

  group('Component Behavior', () {
    testWidgets('Cover dialog handles repeated calls', (tester) async {
      final logs = <String>[];
      void printDebug(String log) => logs.add(log);

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showCover(context, Colors.black54, printDebug);
              showCover(context, Colors.black54, printDebug);
              hideCover(printDebug);
              hideCover(printDebug);
            },
            child: const Text('Test'),
          );
        }),
      ));

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(logs, [
        'Showing the cover',
        'The cover is already shown',
        'Hiding the cover',
        'The cover is already hidden',
      ]);
    });
  });

  group('Configuration Edge Cases', () {
    testWidgets('predialogConfig.modifiedDialogResult overrides dialog',
        (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(MaterialApp(
        home: App(
          tours: [
            FeaturesTour(
              index: 1,
              controller: controller,
              introduce: const Text('a.intro'),
              child: const Text('a'),
            ),
          ],
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      // Test with modifiedDialogResult returning true
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          predialogConfig: PredialogConfig(
            enabled: true,
            modifiedDialogResult: (_) => true,
          ),
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('Introduction'), findsNothing); // Dialog was skipped
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogIsShownWithCustomDialog>(),
          isA<TourPreDialogButtonPressed>().having(
              (s) => s.buttonType, 'accept', PredialogButtonType.accept),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );

      collectedStates.clear();
      resetPredialog();

      // Test with modifiedDialogResult returning false
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          predialogConfig: PredialogConfig(
            enabled: true,
            modifiedDialogResult: (_) => false,
          ),
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('a.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogIsShownWithCustomDialog>(),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'later',
            PredialogButtonType.later,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('ChildConfig applies custom shape and animation settings',
        (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(MaterialApp(
        home: App(
          tours: [
            FeaturesTour(
              index: 1,
              controller: controller,
              introduce: const Text('a.intro'),
              childConfig: ChildConfig(
                shapeBorder: const CircleBorder(),
                isAnimateChild: false,
              ),
              child: const Text('a'),
            ),
          ],
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              // Find the Material widget that draws the border
              final borderMaterial =
                  tester.widgetList<Material>(find.byType(Material)).firstWhere(
                        (m) => m.shape is CircleBorder,
                      );
              expect(borderMaterial.shape, isA<CircleBorder>());
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
    });

    testWidgets('IntroduceConfig applies quadrant alignment', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FeaturesTour(
            index: 1,
            controller: controller,
            introduce: const Text('a.intro'),
            introduceConfig: IntroduceConfig(
              quadrantAlignment: QuadrantAlignment.top,
            ),
            child: const SizedBox(
              key: Key('child'),
              width: 50,
              height: 50,
              child: Placeholder(),
            ),
          ),
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              final introFinder = find.ancestor(
                of: find.text('a.intro'),
                matching: find.byType(Positioned),
              );
              final introRect = tester.getRect(introFinder);
              final childRect =
                  tester.getRect(find.byKey(const Key('child')).first);

              // Intro rect should be above the child rect
              expect(introRect.bottom, lessThanOrEqualTo(childRect.top));

              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
    });
  });

  group('Controller and State Management', () {
    testWidgets('controller stop ends the tour', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(MaterialApp(
        home: App(
          tours: [
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
          ],
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                await tester.tap(find.text('SKIP'));
              } else if (index == 2) {
                // This should not be reached because the tour is stopped.
                fail('Tour should have been stopped before reaching index 2');
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('a.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogNotShown>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.skip,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });
  });
}

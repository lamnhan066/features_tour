import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() {
  List<TourState> collectedStates = [];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    collectedStates = [];

    FeaturesTour.setGlobalConfig(
      force: null,
      predialogConfig: PredialogConfig(enabled: false),
      nextConfig: NextConfig(text: 'NEXT'),
      skipConfig: SkipConfig(text: 'SKIP'),
      doneConfig: DoneConfig(text: 'DONE'),
    );
  });

  group('Core Functionality', () {
    testWidgets('When tour starts, it should show the first feature',
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
          onState: (tourState) async {
            collectedStates.add(tourState);

            if (tourState case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                expect(find.text('b.intro'), findsNothing);
                await tester.tap(find.text('NEXT'));
              } else if (index == 2) {
                await tester.pump();
                expect(find.text('a.intro'), findsNothing);
                expect(find.text('b.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();
      expect(collectedStates.any((e) => e is TourIntroducing), isTrue);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });

    testWidgets('Tapping NEXT shows the next feature', (tester) async {
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
          onState: (tourState) async {
            collectedStates.add(tourState);

            if (tourState case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                expect(find.text('b.intro'), findsNothing);
                await tester.tap(find.text('NEXT'));
              } else if (index == 2) {
                await tester.pump();
                expect(find.text('b.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();
      expect(collectedStates.any((e) => e is TourIntroducing), isTrue);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });

    testWidgets('Tapping SKIP dismisses the tour', (tester) async {
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
          onState: (tourState) async {
            collectedStates.add(tourState);

            if (tourState case TourIntroducing(index: 1)) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              await tester.tap(find.text('SKIP'));
            }
          },
        );
      });

      await tester.pumpAndSettle();
      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });

    testWidgets('Tapping DONE on last feature dismisses the tour',
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
            FeaturesTour(
              index: 2,
              controller: controller,
              introduce: const Text('b.intro'),
              doneConfig: DoneConfig(enabled: true),
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
          onState: (tourState) async {
            collectedStates.add(tourState);

            if (tourState case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                await tester.tap(find.text('NEXT'));
              } else if (index == 2) {
                await tester.pump();
                expect(find.text('b.intro'), findsOneWidget);
                expect(find.text('DONE'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();
      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });
  });

  group('Configuration', () {
    testWidgets('Previously seen tours are not shown again without force',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'FeaturesTour_App_1.0': true,
        'FeaturesTour_App_2.0': true,
      });

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
          delay: Duration.zero,
          onState: (progress) {
            collectedStates.add(progress);
          },
        );
      });
      await tester.pumpAndSettle();

      expect(collectedStates.any((e) => e is TourEmptyStates), isTrue);
    });

    testWidgets('nextIndex waits for the specified feature to appear',
        (tester) async {
      final controller = FeaturesTourController('App');
      final showSecond = ValueNotifier(false);

      await tester.pumpWidget(MaterialApp(
        home: ValueListenableBuilder<bool>(
          valueListenable: showSecond,
          builder: (context, value, child) {
            return App(
              tours: [
                FeaturesTour(
                  index: 1,
                  controller: controller,
                  introduce: const Text('a.intro'),
                  nextIndex: 2,
                  child: const Text('a'),
                  onAfterIntroduce: (_) {
                    showSecond.value = true;
                  },
                ),
                if (value)
                  FeaturesTour(
                    index: 2,
                    controller: controller,
                    introduce: const Text('b.intro'),
                    child: const Text('b'),
                  ),
              ],
            );
          },
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (progress) async {
            collectedStates.add(progress);

            if (progress case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                expect(find.text('b.intro'), findsNothing);
                await tester.tap(find.text('NEXT'));
              } else if (index == 2) {
                await tester.pump();
                expect(showSecond.value, isTrue);
                expect(find.text('a.intro'), findsNothing);
                expect(find.text('b.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }

            if (progress is TourAfterIntroduceCalled) {
              await tester.pump();
              expect(showSecond.value, isTrue);
              await tester.pump();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(collectedStates.any((e) => e is TourIntroducing), isTrue);
      expect(collectedStates.any((e) => e is TourAfterIntroduceCalled), isTrue);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });
  });

  group('Callbacks', () {
    testWidgets('onBeforeIntroduce is called before showing the intro',
        (tester) async {
      final controller = FeaturesTourController('App');
      bool called = false;

      await tester.pumpWidget(MaterialApp(
        home: App(
          tours: [
            FeaturesTour(
              index: 1,
              controller: controller,
              introduce: const Text('a.intro'),
              child: const Text('a'),
              onBeforeIntroduce: () {
                called = true;
              },
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
          onState: (progress) async {
            collectedStates.add(progress);

            if (progress is TourIntroducing) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(collectedStates.any((e) => e is TourIntroducing), isTrue);
      expect(
          collectedStates.any((e) => e is TourBeforeIntroduceCalled), isTrue);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });
  });

  group('Predialog', () {
    testWidgets('Tapping "Okay" in predialog starts the tour', (tester) async {
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

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          predialogConfig: PredialogConfig(
            enabled: true,
            title: 'Introduction',
            acceptButtonText: Text('Okay'),
          ),
          onState: (progress) async {
            collectedStates.add(progress);

            if (progress is TourPreDialogIsShown) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
              await tester.tap(find.text('Okay'));
            }

            if (progress case TourIntroducing(index: final index)) {
              if (index == 1) {
                await tester.pump();
                expect(find.text('a.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }
          },
        );
      });
      await tester.pumpAndSettle();

      expect(collectedStates.any((e) => e is TourPreDialogIsShown), isTrue);
      expect(collectedStates.any((e) => e is TourIntroducing), isTrue);
      expect(collectedStates.any((e) => e is TourCompleted), isTrue);
    });

    testWidgets('Tapping "Later" in predialog dismisses the tour for now',
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

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          predialogConfig: PredialogConfig(
            enabled: true,
            title: 'Introduction',
            laterButtonText: Text('Later'),
          ),
          onState: (progress) async {
            collectedStates.add(progress);

            if (progress is TourPreDialogIsShown) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
              await tester.tap(find.text('Later'));
            }
          },
        );
      });

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogIsShown>(),
          isA<TourPreDialogLaterButtonPressed>(),
        ]),
      );
    });

    testWidgets(
        'Tapping "Dismiss" with "Apply to all" dismisses all tours permanently',
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

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          predialogConfig: PredialogConfig(
            enabled: true,
            title: 'Introduction',
            dismissButtonText: Text('Dismiss'),
            applyToAllPagesText: 'Apply to all',
          ),
          onState: (progress) async {
            collectedStates.add(progress);

            if (progress is TourPreDialogIsShown) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
              expect(find.text('Apply to all'), findsOneWidget);

              await tester.tap(find.byType(Checkbox));
              await tester.pumpAndSettle();
              await tester.tap(find.text('Dismiss'));
              await tester.pumpAndSettle();
            }
          },
        );
      });

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('FeaturesTour_DismissAllTours'), isTrue);
    });
  });
}

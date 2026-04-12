import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/components/unfeatures_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() {
  var collectedStates = <TourState>[];

  setUp(() {
    FeaturesTour.setTestingLogger(const LiteLogger(minLevel: LogLevel.debug));
    resetPreDialog();
    SharedPreferences.setMockInitialValues({});
    collectedStates = [];

    // Reset the global state for pre-dialogs between tests
    FeaturesTour.setGlobalConfig(
      preDialogConfig: PreDialogConfig(enabled: false),
      nextConfig: NextConfig(text: 'NEXT'),
      skipConfig: SkipConfig(text: 'SKIP'),
      doneConfig: DoneConfig(text: 'DONE'),
    );
  });

  group('Core Functionality', () {
    testWidgets('When tour starts, it should show the first feature', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tapping NEXT shows the next feature', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                introduceConfig: RoundedRectIntroduceConfig(),
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
        ),
      );

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

      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.next,
            'IntroduceResult.next',
            true,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tapping PREVIOUS returns to the prior feature', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      var returnedToFirstFeature = false;

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
                if (!returnedToFirstFeature) {
                  expect(find.text('PREVIOUS'), findsNothing);
                  await tester.tap(find.text('NEXT'));
                } else {
                  expect(find.text('PREVIOUS'), findsNothing);
                  await tester.tap(find.text('SKIP'));
                }
              } else if (index == 2) {
                await tester.pump();
                expect(find.text('b.intro'), findsOneWidget);
                expect(find.text('PREVIOUS'), findsOneWidget);
                returnedToFirstFeature = true;
                await tester.tap(find.text('PREVIOUS'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.next,
            'IntroduceResult.next',
            true,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.previous,
            'IntroduceResult.previous',
            true,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.skip,
            'IntroduceResult.skip',
            true,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tapping SKIP dismisses the tour', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);

            if (state case TourIntroducing(index: 1)) {
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
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.skip,
            'IntroduceResult.skip',
            true,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Programmatic next and dismiss complete the tour', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
              await tester.pump();

              if (index == 1) {
                expect(find.text('a.intro'), findsOneWidget);
                expect(controller.next(), isTrue);
              } else if (index == 2) {
                expect(find.text('b.intro'), findsOneWidget);
                expect(controller.skip(), isTrue);
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.next,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.skip,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tapping DONE on last feature dismisses the tour', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.done,
            'IntroduceResult.done',
            true,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });
  });

  group('Configuration', () {
    testWidgets('Previously seen tours are not shown again without force', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'FeaturesTour_App_1.0': true,
        'FeaturesTour_App_2.0': true,
      });

      final controller = FeaturesTourController('App');
      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          delay: Duration.zero,
          onState: (state) {
            collectedStates.add(state);
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([isA<TourEmpty>(), isA<TourCompleted>()]),
      );
    });

    testWidgets('Previously seen tours are shown again with force', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'FeaturesTour_App_1.0': true,
        'FeaturesTour_App_2.0': true,
      });

      final controller = FeaturesTourController('App');
      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result == IntroduceResult.done,
            'IntroduceResult.done',
            true,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('nextIndex waits for the specified feature to appear', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      final showSecond = ValueNotifier(false);

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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

            if (state is TourAfterIntroduceCalled) {
              await tester.pump();
              expect(showSecond.value, isTrue);
              await tester.pump();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourAfterIntroduceCalled>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tour skips features with enabled: false', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                enabled: false,
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
        ),
      );

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
              // It should go directly to index 2
              expect(index, 2);
              await tester.pump();
              expect(find.text('a.intro'), findsNothing);
              expect(find.text('b.intro'), findsOneWidget);
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });
  });

  group('Callbacks', () {
    testWidgets('onBeforeIntroduce is called before showing the intro', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
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

      expect(called, isTrue);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourBeforeIntroduceCalled>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('onAfterIntroduce is called after showing the intro', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      var called = false;
      IntroduceResult? receivedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                child: const Text('a'),
                onAfterIntroduce: (result) {
                  called = true;
                  receivedResult = result;
                },
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
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

      expect(called, isTrue);
      expect(receivedResult, IntroduceResult.done);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourAfterIntroduceCalled>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Previous callbacks wrap the previous action', (tester) async {
      final controller = FeaturesTourController('App');
      final events = <String>[];
      var returnedToFirstFeature = false;

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                child: const Text('a'),
                onAfterIntroduce: (result) {
                  events.add('feature1.afterIntroduce:${result.name}');
                },
              ),
              FeaturesTour(
                index: 2,
                controller: controller,
                introduce: const Text('b.intro'),
                child: const Text('b'),
                onBeforePrevious: () {
                  events.add('feature2.beforePrevious');
                },
                onAfterIntroduce: (result) {
                  events.add('feature2.afterIntroduce:${result.name}');
                },
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);

            if (state case TourIntroduceResultEmitted(
              result: IntroduceResult.previous,
            )) {
              events.add('state.previousEmitted');
            }

            if (state case TourIntroducing(index: final index)) {
              await tester.pump();

              if (index == 1) {
                expect(find.text('a.intro'), findsOneWidget);
                if (!returnedToFirstFeature) {
                  await tester.tap(find.text('NEXT'));
                } else {
                  await tester.tap(find.text('SKIP'));
                }
              } else if (index == 2) {
                expect(find.text('b.intro'), findsOneWidget);
                expect(find.text('PREVIOUS'), findsOneWidget);
                returnedToFirstFeature = true;
                await tester.tap(find.text('PREVIOUS'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(events, [
        'feature1.afterIntroduce:next',
        'feature2.beforePrevious',
        'feature2.afterIntroduce:previous',
        'state.previousEmitted',
        'feature1.afterIntroduce:skip',
      ]);
      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.next,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.previous,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.skip,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('controller.previous matches PREVIOUS callback behavior', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      final events = <String>[];
      var returnedToFirstFeature = false;

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                child: const Text('a'),
                onAfterIntroduce: (result) {
                  events.add('feature1.afterIntroduce:${result.name}');
                },
              ),
              FeaturesTour(
                index: 2,
                controller: controller,
                introduce: const Text('b.intro'),
                child: const Text('b'),
                onBeforePrevious: () {
                  events.add('feature2.beforePrevious');
                },
                onAfterIntroduce: (result) {
                  events.add('feature2.afterIntroduce:${result.name}');
                },
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);

            if (state case TourIntroduceResultEmitted(
              result: IntroduceResult.previous,
            )) {
              events.add('state.previousEmitted');
            }

            if (state case TourIntroducing(index: final index)) {
              await tester.pump();

              if (index == 1) {
                expect(find.text('a.intro'), findsOneWidget);
                if (!returnedToFirstFeature) {
                  await tester.tap(find.text('NEXT'));
                } else {
                  await tester.tap(find.text('SKIP'));
                }
              } else if (index == 2) {
                expect(find.text('b.intro'), findsOneWidget);
                returnedToFirstFeature = true;
                final didMovePrevious = controller.previous();
                expect(didMovePrevious, isTrue);
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(events, [
        'feature1.afterIntroduce:next',
        'feature2.beforePrevious',
        'feature2.afterIntroduce:previous',
        'state.previousEmitted',
        'feature1.afterIntroduce:skip',
      ]);
      expect(find.text('a.intro'), findsNothing);
      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.next,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.previous,
          ),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.skip,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('controller.previous returns false when no previous exists', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      var didAttemptPrevious = false;

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);

            if (state case TourIntroducing(index: 1)) {
              await tester.pump();
              final moved = controller.previous();
              didAttemptPrevious = true;
              expect(moved, isFalse);
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(didAttemptPrevious, isTrue);
      final previousResults = collectedStates
          .whereType<TourIntroduceResultEmitted>()
          .where((state) => state.result == IntroduceResult.previous);
      expect(previousResults, isEmpty);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.done,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('controller.previous returns false outside active introduce', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      expect(controller.previous(), isFalse);

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state case TourIntroducing(index: 1)) {
              await tester.pump();
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();
      expect(controller.previous(), isFalse);
    });

    testWidgets(
      'controller.previous does not call onBeforePrevious when unavailable',
      (tester) async {
        final controller = FeaturesTourController('App');
        var beforePreviousCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: App(
              tours: [
                FeaturesTour(
                  index: 1,
                  controller: controller,
                  introduce: const Text('a.intro'),
                  child: const Text('a'),
                  onBeforePrevious: () {
                    beforePreviousCalled = true;
                  },
                ),
              ],
            ),
          ),
        );

        await tester.pumpAndSettle();
        final context = tester.element(find.byType(App));

        await tester.runAsync(() async {
          await controller.start(
            context,
            force: true,
            delay: Duration.zero,
            onState: (state) async {
              if (state case TourIntroducing(index: 1)) {
                await tester.pump();
                expect(controller.previous(), isFalse);
                await tester.tap(find.text('DONE'));
              }
            },
          );
        });

        await tester.pumpAndSettle();
        expect(beforePreviousCalled, isFalse);
      },
    );

    testWidgets('controller.previous completes only once per introduction', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');
      var previousTriggeredTwice = false;
      var returnedToFirstFeature = false;

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

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
              await tester.pump();

              if (index == 1) {
                if (!returnedToFirstFeature) {
                  await tester.tap(find.text('NEXT'));
                } else {
                  await tester.tap(find.text('SKIP'));
                }
              } else if (index == 2) {
                final first = controller.previous();
                final second = controller.previous();
                expect(first, isTrue);
                expect(second, isFalse);
                previousTriggeredTwice = true;
                returnedToFirstFeature = true;
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(previousTriggeredTwice, isTrue);
      final previousResults =
          collectedStates
              .whereType<TourIntroduceResultEmitted>()
              .where((state) => state.result == IntroduceResult.previous)
              .toList();
      expect(previousResults.length, 1);
    });
  });

  group('PreDialog', () {
    testWidgets('Tapping "Okay" in pre-dialog starts the tour', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(
            enabled: true,
            title: 'Introduction',
            acceptButtonLabel: 'Okay',
          ),
          onState: (state) async {
            collectedStates.add(state);

            if (state is TourPreDialogShownDefault) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
              await tester.tap(find.text('Okay'));
            }

            if (state case TourIntroducing(index: final index)) {
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

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogShownDefault>(),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'buttonType',
            PreDialogButtonType.accept,
          ),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tapping "Later" in pre-dialog dismisses the tour for now', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(
            enabled: true,
            title: 'Introduction',
            laterButtonLabel: 'Later',
          ),
          onState: (state) async {
            collectedStates.add(state);

            if (state is TourPreDialogShownDefault) {
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
          isA<TourPreDialogShownDefault>(),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'buttonType',
            PreDialogButtonType.later,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets(
      'Tapping "Dismiss" with "Apply to all" dismisses all tours permanently',
      (tester) async {
        final controller = FeaturesTourController('App');

        await tester.pumpWidget(
          MaterialApp(
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
          ),
        );

        await tester.pumpAndSettle();
        final context = tester.element(find.byType(App));

        await tester.runAsync(() async {
          await controller.start(
            context,
            force: true,
            delay: Duration.zero,
            preDialogConfig: PreDialogConfig(
              enabled: true,
              title: 'Introduction',
              dismissButtonLabel: 'Dismiss',
              applyToAllCheckboxLabel: 'Apply to all',
            ),
            onState: (state) async {
              collectedStates.add(state);

              if (state is TourPreDialogShownDefault) {
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
        expect(
          collectedStates,
          containsAllInOrder([
            isA<TourPreDialogShownDefault>(),
            isA<TourPreDialogApplyToAllChanged>().having(
              (s) => s.isChecked,
              'isChecked',
              true,
            ),
            isA<TourPreDialogButtonPressed>().having(
              (s) => s.buttonType,
              'buttonType',
              PreDialogButtonType.dismiss,
            ),
            isA<TourCompleted>(),
          ]),
        );
      },
    );

    testWidgets(
      'Tapping "Okay" with "Apply to all" accepts for all subsequent tours',
      (tester) async {
        final controller1 = FeaturesTourController('Page1');
        final controller2 = FeaturesTourController('Page2');

        // Start with page 1
        await tester.pumpWidget(
          MaterialApp(
            home: App(
              key: const Key('Page1'),
              tours: [
                FeaturesTour(
                  index: 1,
                  controller: controller1,
                  introduce: const Text('page1.intro'),
                  child: const Text('page1'),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context1 = tester.element(find.byKey(const Key('Page1')));

        // Show pre-dialog for page 1, check "apply to all" and accept
        await tester.runAsync(() async {
          await controller1.start(
            context1,
            force: true,
            delay: Duration.zero,
            preDialogConfig: PreDialogConfig(
              enabled: true,
              title: 'Introduction',
              acceptButtonLabel: 'Okay',
              applyToAllCheckboxLabel: 'Apply to all',
            ),
            onState: (state) async {
              collectedStates.add(state);
              if (state is TourPreDialogShownDefault) {
                await tester.pump();
                expect(find.text('Introduction'), findsOneWidget);
                final checkbox = find.byType(Checkbox);
                await tester.tap(checkbox);
                await tester.pump();
                await tester.tap(find.text('Okay'));
              }
              if (state is TourIntroducing) {
                await tester.pump();
                await tester.tap(find.text('DONE'));
              }
            },
          );
        });
        await tester.pumpAndSettle();

        expect(
          collectedStates,
          containsAllInOrder([
            isA<TourPreDialogShownDefault>(),
            isA<TourPreDialogApplyToAllChanged>().having(
              (s) => s.isChecked,
              'isChecked',
              true,
            ),
            isA<TourPreDialogButtonPressed>().having(
              (s) => s.buttonType,
              'buttonType',
              PreDialogButtonType.accept,
            ),
            isA<TourIntroducing>(),
            isA<TourIntroduceResultEmitted>(),
            isA<TourCompleted>(),
          ]),
        );

        // Now switch to page 2
        collectedStates.clear();
        await tester.pumpWidget(
          MaterialApp(
            home: App(
              key: const Key('Page2'),
              tours: [
                FeaturesTour(
                  index: 1,
                  controller: controller2,
                  introduce: const Text('page2.intro'),
                  child: const Text('page2'),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context2 = tester.element(find.byKey(const Key('Page2')));

        // Start tour for page 2, pre-dialog should be skipped
        await tester.runAsync(() async {
          await controller2.start(
            context2,
            force: true,
            delay: Duration.zero,
            preDialogConfig: PreDialogConfig(enabled: true),
            onState: (state) async {
              collectedStates.add(state);
              if (state is TourIntroducing) {
                await tester.pump();
                expect(find.text('page2.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            },
          );
        });
        await tester.pumpAndSettle();

        // Verify pre-dialog was not shown for the second tour
        expect(collectedStates.whereType<TourPreDialogShownDefault>(), isEmpty);
        expect(
          collectedStates,
          containsAllInOrder([
            isA<TourPreDialogHiddenByAppliedToAll>().having(
              (s) => s.buttonType,
              'buttonType',
              PreDialogButtonType.accept,
            ),
            isA<TourPreDialogButtonPressed>(),
            isA<TourIntroducing>(),
            isA<TourIntroduceResultEmitted>(),
            isA<TourCompleted>(),
          ]),
        );
      },
    );
  });

  group('Advanced Scenarios', () {
    testWidgets('nextIndex times out and proceeds to next available feature', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                nextIndex: 99, // This index will never appear
                nextIndexTimeout: const Duration(milliseconds: 100),
                child: const Text('a'),
              ),
              FeaturesTour(
                index: 3,
                controller: controller,
                introduce: const Text('c.intro'),
                child: const Text('c'),
              ),
            ],
          ),
        ),
      );

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
                await tester.tap(find.text('NEXT'));
                // Wait for timeout
                await tester.pump(const Duration(milliseconds: 150));
              } else if (index == 3) {
                await tester.pump();
                expect(find.text('a.intro'), findsNothing);
                expect(find.text('c.intro'), findsOneWidget);
                await tester.tap(find.text('DONE'));
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // The tour should have proceeded to index 3 after timeout
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 3),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('UnfeaturesTour widget prevents tour for descendants', (
      tester,
    ) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
          home: App(
            tours: [
              FeaturesTour(
                index: 1,
                controller: controller,
                introduce: const Text('a.intro'),
                child: const Text('a'),
              ),
              UnfeaturesTour(
                child: FeaturesTour(
                  index: 2,
                  controller: controller,
                  introduce: const Text('b.intro'),
                  child: const Text('b'),
                ),
              ),
            ],
          ),
        ),
      );

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
              // It should only show index 1
              expect(index, 1);
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              // Since it's the last available one, it shows DONE
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(find.text('b.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });
  });
}

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/cover_dialog.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/extensions/get_widget_position.dart';
import 'package:features_tour/src/features_tour.dart'
    show DismissAllTourStorage;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

class BuildContextFake implements BuildContext {
  @override
  bool get mounted => false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // Implement any methods that are called during the test, or throw if unexpected
    throw UnsupportedError(
      'BuildContextFake does not support ${invocation.memberName}',
    );
  }
}

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

  group('Static Methods and Storage', () {
    testWidgets('FeaturesTour.removeAll marks all tours as shown', (
      tester,
    ) async {
      final controller1 = FeaturesTourController('Page1');
      final controller2 = FeaturesTourController('Page2');
      await tester.pumpWidget(
        MaterialApp(
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
        ),
      );
      await tester.pumpAndSettle();

      // At this point, controllers are registered and have states.
      await FeaturesTour.removeAll();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('FeaturesTour_Page1_1.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_Page2_1.0'), isTrue);
    });

    testWidgets('DismissAllTourStorage saves and retrieves dismissal state', (
      tester,
    ) async {
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
    testWidgets('showCover does not show when context is not mounted', (
      tester,
    ) async {
      final logs = <String>[];
      void printDebug(String log) => logs.add(log);

      // Create a context that is not mounted
      final unmountedContext = BuildContextFake();

      showCover(unmountedContext, Colors.black54, printDebug);

      expect(logs, [
        'Cannot show the cover because the build context is not mounted',
      ]);
      expect(
        find.byType(Material),
        findsNothing,
      ); // Ensure no overlay is inserted
    });

    testWidgets('pre-dialog handles error in onShownPreDialog', (tester) async {
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

      Object? caughtError;
      StackTrace? caughtStackTrace;

      await tester.runAsync(() async {
        try {
          await controller.start(
            context,
            force: true,
            delay: Duration.zero,
            preDialogConfig: PreDialogConfig(enabled: true),
            onState: (state) async {
              if (state is TourPreDialogShownDefault) {
                // Simulate an error in onShownPreDialog
                throw Exception('Simulated error in onShownPreDialog');
              }
            },
          );
        } on Exception catch (e, st) {
          caughtError = e;
          caughtStackTrace = st;
        }
      });

      expect(caughtError, isA<Exception>());
      expect(
        caughtError.toString(),
        contains('Simulated error in onShownPreDialog'),
      );
      expect(caughtStackTrace, isNotNull);

      // Ensure the overlay is removed even if an error occurs
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('resetPreDialog resets the cached pre-dialog selection', (
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

      // First, make a selection that gets cached (e.g., "Later" with "Apply to all")
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(
            enabled: true,
            laterButtonLabel: 'Later',
            dismissButtonLabel: 'Dismiss',
            applyToAllCheckboxLabel: 'Apply to all',
          ),
          onState: (state) async {
            if (state is TourPreDialogShownDefault) {
              await tester.pump();
              await tester.tap(find.byType(Checkbox));
              await tester.pumpAndSettle();
              await tester.tap(find.text('Later'));
            }
          },
        );
      });
      await tester.pumpAndSettle();

      // Now, start the tour again. It should skip the pre-dialog due to caching.
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(enabled: true),
          onState: (state) {
            collectedStates.add(state);
          },
        );
      });
      await tester.pump();

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHiddenByAppliedToAll>().having(
            (s) => s.buttonType,
            'buttonType',
            PreDialogButtonType.later,
          ),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'buttonType',
            PreDialogButtonType.later,
          ),
          isA<TourCompleted>(),
        ]),
      );

      collectedStates.clear();
      // Reset the pre-dialog cache
      resetPreDialog();

      // Start the tour a third time. The pre-dialog should now appear again.
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(enabled: true),
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourPreDialogShownDefault) {
              await tester.pump();
              // Dismiss the dialog to complete the flow
              await tester.tap(find.text('Dismiss'));
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
            PreDialogButtonType.dismiss,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Cover dialog handles repeated calls', (tester) async {
      final logs = <String>[];
      void printDebug(String log) => logs.add(log);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  showCover(context, Colors.black54, printDebug);
                  showCover(context, Colors.black54, printDebug);
                  hideCover(printDebug);
                  hideCover(printDebug);
                },
                child: const Text('Test'),
              );
            },
          ),
        ),
      );

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

  group('Extensions', () {
    testWidgets('GlobalKeyExtension.globalPaintBounds returns correct Rect', (
      tester,
    ) async {
      final globalKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox(
              key: globalKey,
              width: 100,
              height: 50,
              child: const Placeholder(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final rect = globalKey.globalPaintBounds;
      expect(rect, isNotNull);
      expect(rect!.width, 100);
      expect(rect.height, 50);

      // Verify position (center of screen)
      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final screenHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      expect(rect.left, closeTo((screenWidth - 100) / 2, 1.0));
      expect(rect.top, closeTo((screenHeight - 50) / 2, 1.0));
    });
  });

  group('Configuration Edge Cases', () {
    testWidgets('pre-dialogConfig.customDialogBuilder overrides dialog', (
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

      // Test with modifiedDialogResult returning true
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(
            enabled: true,
            customDialogBuilder: (_, _) async => PreDialogButtonType.accept,
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
          isA<TourPreDialogShownCustom>(),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'accept',
            PreDialogButtonType.accept,
          ),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );

      collectedStates.clear();
      resetPreDialog();

      // Test with modifiedDialogResult returning false
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          preDialogConfig: PreDialogConfig(
            enabled: true,
            customDialogBuilder: (_, _) => PreDialogButtonType.later,
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
          isA<TourPreDialogShownCustom>(),
          isA<TourPreDialogButtonPressed>().having(
            (s) => s.buttonType,
            'later',
            PreDialogButtonType.later,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('ChildConfig applies custom shape and animation settings', (
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
                childConfig: ChildConfig(
                  shapeBorder: const CircleBorder(),
                  isAnimateChild: false,
                ),
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
            if (state is TourIntroducing) {
              await tester.pump();
              // Find the Material widget that draws the border
              final borderMaterial = tester
                  .widgetList<Material>(find.byType(Material))
                  .firstWhere((m) => m.shape is CircleBorder);
              expect(borderMaterial.shape, isA<CircleBorder>());
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
    });

    testWidgets('IntroduceConfig applies quadrant alignment', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(
        MaterialApp(
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
            if (state is TourIntroducing) {
              await tester.pump();
              final introFinder = find.ancestor(
                of: find.text('a.intro'),
                matching: find.byType(Positioned),
              );
              final introRect = tester.getRect(introFinder);
              final childRect = tester.getRect(
                find.byKey(const Key('child')).first,
              );

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
          isA<TourPreDialogHidden>(),
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

    testWidgets('next() should move to next step', (tester) async {
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
                // Programmatically complete with next
                controller.next();
              } else if (index == 2) {
                expect(find.text('b.intro'), findsOneWidget);
                controller.done();
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

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
            IntroduceResult.done,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('skip() should stop the tour', (tester) async {
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
                // Programmatically skip the entire tour
                controller.skip();
              } else if (index == 2) {
                fail('Should not reach index 2 after skip');
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
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

    testWidgets('done() should complete the tour', (tester) async {
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
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              // Complete with done result
              controller.done();
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
          isA<TourIntroduceResultEmitted>().having(
            (s) => s.result,
            'result',
            IntroduceResult.done,
          ),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('next() should do nothing when tour is not active', (
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

      // Call complete before starting the tour - should not crash
      controller.next();

      // Verify app is still functional
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets(
      'next() and done() can be used with external events like timers',
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

        var firstIntroShown = false;
        var secondIntroShown = false;

        await tester.runAsync(() async {
          // Start tour with state tracking
          final tourFuture = controller.start(
            context,
            force: true,
            delay: Duration.zero,
            onState: (state) async {
              collectedStates.add(state);
              if (state case TourIntroducing(index: final index)) {
                await tester.pump();
                if (index == 1) {
                  firstIntroShown = true;
                } else if (index == 2) {
                  secondIntroShown = true;
                }
              }
            },
          );

          // Wait for first introduction to appear
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(firstIntroShown, isTrue);

          // Simulate external event (e.g., timer) completing the tour
          controller.next();

          // Wait for transition to second introduction
          await tester.pump();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          expect(secondIntroShown, isTrue);

          // Complete the tour
          controller.done();

          // Wait for tour to finish
          await tourFuture;
        });

        await tester.pumpAndSettle();

        // Verify tour completed successfully
        expect(find.text('a.intro'), findsNothing);
        expect(find.text('b.intro'), findsNothing);
        expect(
          collectedStates,
          containsAllInOrder([
            isA<TourIntroducing>().having((s) => s.index, 'index', 1),
            isA<TourIntroducing>().having((s) => s.index, 'index', 2),
            isA<TourCompleted>(),
          ]),
        );
      },
    );

    testWidgets('reset() clears shown flags from target index onwards', (
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

      // First, complete the entire tour
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Verify all tours are marked as shown
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('FeaturesTour_App_1.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_App_2.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_App_3.0'), isTrue);

      // Reset from index 2.0 onwards
      await controller.reset(2);

      // Need to reload prefs to get updated values
      await prefs.reload();

      // Verify flags are cleared for index 2.0 and 3.0, but not 1.0
      expect(prefs.getBool('FeaturesTour_App_1.0'), isTrue);
      expect(prefs.containsKey('FeaturesTour_App_2.0'), isFalse);
      expect(prefs.containsKey('FeaturesTour_App_3.0'), isFalse);
    });

    testWidgets('reset() allows re-showing tours from target index', (
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

      // Complete the tour first
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Reset from index 2.0
      await controller.reset(2);

      collectedStates.clear();

      // Restart the tour with force: true
      await tester.runAsync(() async {
        await controller.start(
          context,
          firstIndex: 2,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Should show index 2 and 3 but not 1
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroducing>().having((s) => s.index, 'index', 3),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('reset() cancels currently running tour', (tester) async {
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
        // Start the tour
        final tourFuture = controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state case TourIntroducing(index: 1)) {
              await tester.pump();
              // Reset while tour is running
              await controller.reset(1);
            }
          },
        );

        await tourFuture;
      });

      await tester.pumpAndSettle();

      // Tour should be cancelled with skip
      expect(
        collectedStates,
        containsAllInOrder([
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

    testWidgets('reset() with index 1.0 clears all shown flags', (
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

      // Complete the tour
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Verify all are marked as shown
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('FeaturesTour_App_1.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_App_2.0'), isTrue);

      // Reset from the beginning
      await controller.reset(1);

      // Need to reload prefs to get updated values
      await prefs.reload();

      // All flags should be cleared
      expect(prefs.containsKey('FeaturesTour_App_1.0'), isFalse);
      expect(prefs.containsKey('FeaturesTour_App_2.0'), isFalse);
    });

    testWidgets('reset() restores all cached states to active states', (
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

      // Complete the tour (this unregisters states)
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Reset from index 1.0
      await controller.reset(1);

      collectedStates.clear();

      // Restart - should be able to show all tours again
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Both tours should be shown
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('reset() works correctly for implementing go-to-previous', (
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

      // Show first two tours
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state case TourIntroducing(index: final index)) {
              await tester.pump();
              if (index == 1 || index == 2) {
                controller.next();
              } else if (index == 3) {
                // User wants to go back to index 2
                controller.skip();
              }
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Reset to index 2 to go back
      await controller.reset(2);

      collectedStates.clear();

      // Restart from index 2
      await tester.runAsync(() async {
        await controller.start(
          context,
          firstIndex: 2,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Should show index 2 and 3
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroducing>().having((s) => s.index, 'index', 3),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('reset() does nothing when no tours have been shown', (
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

      // Call reset before starting any tour - should not crash
      await controller.reset(1);

      // Verify app is still functional
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('reset() with non-existent index still works', (tester) async {
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

      // Complete the tour
      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) async {
            if (state is TourIntroducing) {
              await tester.pump();
              controller.next();
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Reset with index that doesn't exist (e.g., 5.0)
      await controller.reset(5);

      final prefs = await SharedPreferences.getInstance();
      // All existing flags should still be there (no index >= 5.0 exists)
      expect(prefs.getBool('FeaturesTour_App_1.0'), isTrue);
      expect(prefs.getBool('FeaturesTour_App_2.0'), isTrue);
    });
  });
}

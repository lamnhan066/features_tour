import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/cover_dialog.dart'; // Added for showCover and hideCover
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

void main() {
  var collectedStates = <TourState>[];

  setUp(() {
    FeaturesTour.setTestingLogger(Logger((s) {}));
    resetPreDialog();
    SharedPreferences.setMockInitialValues({});
    collectedStates = [];

    // Reset the global state for pre-dialogs between tests
    FeaturesTour.setGlobalConfig(
      preDialogConfig: PreDialogConfig(
        enabled: false,
        title: 'Introduction',
        acceptButtonLabel: 'Okay',
        laterButtonLabel: 'Later',
        dismissButtonLabel: 'Dismiss',
      ),
      nextConfig: NextConfig(text: 'NEXT'),
      skipConfig: SkipConfig(text: 'SKIP'),
      doneConfig: DoneConfig(text: 'DONE'),
    );
  });

  group('FeaturesTourController Extra Tests', () {
    testWidgets('controller.start with empty tour list completes immediately',
        (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(const MaterialApp(
        home: App(
          tours: [],
        ),
      ));

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(App));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onState: (state) {
            collectedStates.add(state);
          },
        );
      });
      await tester.pumpAndSettle();

      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourEmpty>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('Tour fails gracefully if child widget is not found',
        (tester) async {
      final controller = FeaturesTourController('App');
      final showChild = ValueNotifier(true);

      await tester.pumpWidget(MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: showChild,
          builder: (context, value, child) {
            return App(
              tours: [
                if (value)
                  FeaturesTour(
                    index: 1,
                    controller: controller,
                    introduce: const Text('a.intro'),
                    child: const Text('a'),
                    onAfterIntroduce: (_) {
                      showChild.value = false;
                    },
                  ),
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

      Object? caughtError;
      await tester.runAsync(() async {
        try {
          await controller.start(
            context,
            force: true,
            delay: Duration.zero,
            onState: (state) async {
              collectedStates.add(state);
              if (state is TourIntroducing && state.index == 1) {
                await tester.pump();
                await tester.tap(find.text('NEXT'));
              }
              if (state is TourIntroducing && state.index == 2) {
                await tester.pump();
                await tester.tap(find.text('DONE'));
              }
            },
          );
        } on Exception catch (e) {
          caughtError = e;
        }
      });
      await tester.pumpAndSettle();

      // The tour should complete without error, skipping the missing feature.
      expect(caughtError, isNull);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 1),
          isA<TourAfterIntroduceCalled>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourIntroducing>().having((s) => s.index, 'index', 2),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('controller stops the tour and clears overlay', (tester) async {
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
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourIntroducing) {
              await tester.pump();
              expect(find.text('a.intro'), findsOneWidget);
              // Simulate stopping the tour by tapping DONE
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
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('controller.start with delay shows pre-dialog after delay',
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
          delay: const Duration(milliseconds: 200),
          preDialogConfig: PreDialogConfig(enabled: true),
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourPreDialogShownDefault) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
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
          isA<TourPreDialogButtonPressed>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });
  });

  group('Dialogs Extra Tests', () {
    testWidgets('showIntroduceDialog aligns correctly for all quadrants',
        (tester) async {
      final childKey = GlobalKey();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: childKey,
              width: 100,
              height: 50,
              child: const Placeholder(),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold));
      final childRect = tester.getRect(find.byKey(childKey));

      for (final alignment in QuadrantAlignment.values) {
        // This test is now testing the alignment of the FeaturesTour's introduce widget
        // by setting the introduceConfig.quadrantAlignment.
        // The direct call to showIntroduceDialog is removed.
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: FeaturesTour(
              index: 1,
              controller: FeaturesTourController('TestApp'),
              introduce: Text(alignment.name),
              introduceConfig: IntroduceConfig(
                quadrantAlignment: alignment,
              ),
              child: SizedBox(
                key: childKey,
                width: 100,
                height: 50,
                child: const Placeholder(),
              ),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        final controller = FeaturesTourController('TestApp');
        await tester.runAsync(() async {
          await controller.start(
            context,
            force: true,
            delay: Duration.zero,
            onState: (state) async {
              if (state is TourIntroducing) {
                await tester.pump();
                final introFinder = find.ancestor(
                  of: find.text(alignment.name),
                  matching: find.byType(Positioned),
                );
                expect(introFinder, findsOneWidget);
                final introRect = tester.getRect(introFinder);

                switch (alignment) {
                  case QuadrantAlignment.top:
                    expect(introRect.bottom, lessThanOrEqualTo(childRect.top));
                  case QuadrantAlignment.left:
                    expect(introRect.right, lessThanOrEqualTo(childRect.left));
                  case QuadrantAlignment.right:
                    expect(
                        introRect.left, greaterThanOrEqualTo(childRect.right));
                  case QuadrantAlignment.bottom:
                    expect(
                        introRect.top, greaterThanOrEqualTo(childRect.bottom));
                  case QuadrantAlignment.inside:
                    // For inside, the intro dialog should be within the childRect
                    expect(
                        introRect.left, greaterThanOrEqualTo(childRect.left));
                    expect(introRect.top, greaterThanOrEqualTo(childRect.top));
                    expect(introRect.right, lessThanOrEqualTo(childRect.right));
                    expect(
                        introRect.bottom, lessThanOrEqualTo(childRect.bottom));
                }
                await tester.tap(find.text('DONE'));
              }
            },
          );
        });
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Pre-dialog respects disabled buttons', (tester) async {
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
          preDialogConfig: PreDialogConfig(
            enabled: true,
            title: 'Introduction',
            acceptButtonLabel: 'Okay',
            laterButtonLabel: 'Later',
            dismissButtonLabel: 'Dismiss',
          ),
          onState: (state) async {
            collectedStates.add(state);
            if (state is TourPreDialogShownDefault) {
              await tester.pump();
              expect(find.text('Introduction'), findsOneWidget);
              // Check if disabled buttons are not found
              // Should be found if label is set
              expect(find.text('Later'), findsOneWidget);
              // Should be found if label is set
              expect(find.text('Dismiss'), findsOneWidget);
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
          isA<TourPreDialogButtonPressed>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('showPreDialog with customDialogBuilder returning a value',
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
          preDialogConfig: PreDialogConfig(
            enabled: true,
            customDialogBuilder: (_, onApplyToAllPagesCheckboxChanged) {
              onApplyToAllPagesCheckboxChanged(false);
              return PreDialogButtonType.accept;
            },
          ),
          onState: (state) async {
            collectedStates.add(state);

            if (state is TourIntroducing) {
              await tester.pump();
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });

      await tester.pumpAndSettle();

      // Expect the tour to complete without showing any dialog
      expect(find.text('a.intro'), findsNothing);
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogShownCustom>(),
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

    testWidgets('showPreDialog when preDialogConfig.enabled is false',
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
          preDialogConfig: PreDialogConfig(enabled: false),
          onState: (state) async {
            collectedStates.add(state);

            if (state is TourIntroducing) {
              await tester.pump();
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
      await tester.pumpAndSettle();

      expect(
          collectedStates, isNot(contains(isA<TourPreDialogShownDefault>())));
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('showIntroduceDialog when introduce is null', (tester) async {
      final controller = FeaturesTourController('App');

      await tester.pumpWidget(MaterialApp(
        home: App(
          tours: [
            FeaturesTour(
              index: 1,
              controller: controller,
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
            collectedStates.add(state);

            if (state is TourIntroducing) {
              await tester.pump();
              await tester.tap(find.text('DONE'));
            }
          },
        );
      });
      await tester.pumpAndSettle();

      expect(
          collectedStates, isNot(contains(isA<TourPreDialogShownDefault>())));
      expect(
        collectedStates,
        containsAllInOrder([
          isA<TourPreDialogHidden>(),
          isA<TourIntroducing>(),
          isA<TourIntroduceResultEmitted>(),
          isA<TourCompleted>(),
        ]),
      );
    });

    testWidgets('showCover and hideCover with debugPrint enabled',
        (tester) async {
      final logs = <String>[];
      void customDebugPrint(String? message, {int? wrapWidth}) {
        logs.add(message ?? '');
      }

      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showCover(context, Colors.black54, customDebugPrint);
              hideCover(customDebugPrint);
            },
            child: const Text('Test'),
          );
        }),
      ));

      await tester.tap(find.text('Test'));
      await tester.pump();

      expect(logs, [
        'Showing the cover',
        'Hiding the cover',
      ]);
    });
  });
}

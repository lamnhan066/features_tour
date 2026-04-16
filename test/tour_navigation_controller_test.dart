import 'dart:math';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _TourIndex {
  drawer,
  drawerButton,
  settingAction,
  list,
  firstItem,
  item90,
  dialogButton,
  restartTourButton,
  floatingButton,
}

enum _TimeoutStep { first, missing, second }

enum _PreviousTimeoutStep { first, second }

class _TourExpectation {
  const _TourExpectation({
    required this.step,
    required this.actionLabel,
    required this.drawerOpen,
    required this.dialogOpen,
  });

  final Enum step;
  final String actionLabel;
  final bool drawerOpen;
  final bool dialogOpen;
}

class _TimeoutHarness extends StatelessWidget {
  const _TimeoutHarness({required this.controller});

  final FeaturesTourController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FeaturesTour(
            controller: controller,
            step: _TimeoutStep.first,
            nextStep: _TimeoutStep.missing,
            nextStepTimeout: Duration.zero,
            introduce: const Text('First intro'),
            child: const Text('First child'),
          ),
          FeaturesTour(
            controller: controller,
            step: _TimeoutStep.second,
            introduce: const Text('Second intro'),
            child: const Text('Second child'),
          ),
        ],
      ),
    );
  }
}

class _PreviousTimeoutHarness extends StatefulWidget {
  const _PreviousTimeoutHarness({required this.controller});

  final FeaturesTourController controller;

  @override
  State<_PreviousTimeoutHarness> createState() =>
      _PreviousTimeoutHarnessState();
}

class _PreviousTimeoutHarnessState extends State<_PreviousTimeoutHarness> {
  bool _showFirst = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (_showFirst)
            FeaturesTour(
              controller: widget.controller,
              step: _PreviousTimeoutStep.first,
              introduce: const Text('First intro'),
              child: const Text('First child'),
              onAfterAction: (result) {
                if (result == TourAction.next) {
                  setState(() {
                    _showFirst = false;
                  });
                }
              },
            ),
          FeaturesTour(
            controller: widget.controller,
            step: _PreviousTimeoutStep.second,
            previousStepTimeout: Duration.zero,
            introduce: const Text('Second intro'),
            child: const Text('Second child'),
          ),
        ],
      ),
    );
  }
}

class _TourHarness extends StatefulWidget {
  const _TourHarness({required this.controller});

  final FeaturesTourController controller;

  @override
  State<_TourHarness> createState() => _TourHarnessState();
}

class _TourHarnessState extends State<_TourHarness> {
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _drawerOpen = false;
  bool _dialogOpen = false;

  void _openDrawer() {
    setState(() {
      _drawerOpen = true;
    });
  }

  void _closeDrawer() {
    setState(() {
      _drawerOpen = false;
    });
  }

  void _showDialog() {
    setState(() {
      _dialogOpen = true;
    });
  }

  void _hideDialog() {
    setState(() {
      _dialogOpen = false;
    });
  }

  void _jumpToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.jumpTo(0);
  }

  void _jumpToBottom() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Tour Harness'),
        leading: FeaturesTour(
          controller: widget.controller,
          step: _TourIndex.drawer,
          nextStep: _TourIndex.drawerButton,
          introduce: const Text('Tap here to open the drawer'),
          onAfterAction: (result) {
            if (result == TourAction.next || result == TourAction.done) {
              _openDrawer();
            }
          },
          child: IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Open drawer',
            onPressed: _openDrawer,
          ),
        ),
        actions: [
          FeaturesTour(
            controller: widget.controller,
            step: _TourIndex.settingAction,
            introduce: const Text('Tap here to change the brightness'),
            onAfterAction: (action) {
              if (action == TourAction.previous) {
                _openDrawer();
              }
            },
            child: IconButton(
              icon: const Icon(Icons.light_mode),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  FeaturesTour(
                    controller: widget.controller,
                    step: _TourIndex.list,
                    introduce: Text(
                      'This is a list of items',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    introduceConfig: IntroduceConfig(
                      builder: (context, childRect, introduce) {
                        return Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: ColorScheme.of(
                              context,
                            ).primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: introduce,
                        );
                      },
                      quadrantAlignment: QuadrantAlignment.inside,
                    ),
                    childConfig: ChildConfig(enableAnimation: false),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('List section'),
                    ),
                  ),
                  FeaturesTour(
                    controller: widget.controller,
                    step: _TourIndex.firstItem,
                    nextStep: _TourIndex.item90,
                    introduce: const Text('This is the item 0'),
                    onBeforeAction: (action) async {
                      if (action == TourAction.previous) {
                        _jumpToTop();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Item 0'),
                    ),
                  ),
                  for (var index = 1; index <= 100; index++)
                    if (index == 95)
                      FeaturesTour(
                        controller: widget.controller,
                        step: _TourIndex.item90,
                        nextStep: _TourIndex.dialogButton,
                        introduce: Text('This is item $index'),
                        onBeforeAction: (action) async {
                          if (action == TourAction.next ||
                              action == TourAction.previous) {
                            _jumpToBottom();
                          }
                        },
                        onAfterAction: (result) async {
                          if (result == TourAction.previous) {
                            _jumpToTop();
                            return;
                          }

                          if (result == TourAction.next) {
                            _showDialog();
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Item $index'),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Item $index'),
                      ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_drawerOpen,
            child: Opacity(
              opacity: _drawerOpen ? 1 : 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 280,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(context).colorScheme.surface,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _drawerOpen ? 'Drawer is open' : 'Drawer is closed',
                          ),
                          const SizedBox(height: 12),
                          FeaturesTour(
                            controller: widget.controller,
                            step: _TourIndex.drawerButton,
                            introduce: const Text(
                              'Tap here to close the drawer',
                            ),
                            onBeforeAction: (action) {
                              if (action == TourAction.previous) {
                                _openDrawer();
                              }
                            },
                            onAfterAction: (result) {
                              if (result == TourAction.next ||
                                  result == TourAction.done ||
                                  result == TourAction.previous ||
                                  result == TourAction.skip) {
                                _closeDrawer();
                              }
                            },
                            child: ElevatedButton(
                              onPressed: _closeDrawer,
                              child: const Text('Close Drawer'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_dialogOpen,
            child: Opacity(
              opacity: _dialogOpen ? 1 : 0,
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Material(
                    elevation: 24,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _dialogOpen ? 'Dialog is open' : 'Dialog is closed',
                          ),
                          const SizedBox(height: 16),
                          const Text('Tour Dialog'),
                          const SizedBox(height: 16),
                          FeaturesTour(
                            controller: widget.controller,
                            step: _TourIndex.dialogButton,
                            introduce: const Text(
                              'Tap here to close the dialog',
                            ),
                            onAfterAction: (result) {
                              if (result == TourAction.previous ||
                                  result == TourAction.next ||
                                  result == TourAction.done ||
                                  result == TourAction.skip) {
                                _hideDialog();
                              }
                            },
                            child: TextButton(
                              onPressed: _hideDialog,
                              child: const Text('Dialog Step Button'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FeaturesTour(
                        controller: widget.controller,
                        step: _TourIndex.restartTourButton,
                        introduce: const Text('Tap here to run the tour again'),
                        onAfterAction: (action) {
                          if (action == TourAction.previous) {
                            _showDialog();
                          }
                        },
                        childConfig: ChildConfig(
                          shapeBorder: const CircleBorder(),
                          borderSizeInflate: 10,
                        ),
                        child: FloatingActionButton(
                          onPressed: () {
                            widget.controller.start(
                              context,
                              force: true,
                              preDialogConfig: PreDialogConfig(enabled: false),
                            );
                          },
                          child: const Icon(Icons.restart_alt_rounded),
                        ),
                      ),
                      FeaturesTour(
                        controller: widget.controller,
                        step: _TourIndex.floatingButton,
                        introduce: const Text('Tap here to add a new item'),
                        childConfig: ChildConfig(
                          shapeBorder: const CircleBorder(),
                          borderSizeInflate: 10,
                        ),
                        child: FloatingActionButton(
                          onPressed: () {},
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                  FeaturesTourPadding(
                    controller: widget.controller,
                    indexes: {7.0, 8.0},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  testWidgets('walks next through all widgets and completes (controller)', (
    tester,
  ) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];

    final expectations = <_TourExpectation>[
      const _TourExpectation(
        step: _TourIndex.drawer,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.drawerButton,
        actionLabel: 'NEXT',
        drawerOpen: true,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.settingAction,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.list,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.firstItem,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.item90,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.dialogButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: true,
      ),
      const _TourExpectation(
        step: _TourIndex.restartTourButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        step: _TourIndex.floatingButton,
        actionLabel: 'DONE',
        drawerOpen: false,
        dialogOpen: false,
      ),
    ];

    var stepIndex = 0;

    await tester.pumpWidget(
      MaterialApp(home: _TourHarness(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_TourHarness));

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
            expect(stepIndex, lessThan(expectations.length));

            final expectation = expectations[stepIndex];
            expect(step, expectation.step);
            expect(index, expectation.step.index.toDouble());

            await tester.pump();

            // Use controller methods instead of tapping widgets
            switch (expectation.actionLabel) {
              case 'NEXT':
                expect(controller.next(), isTrue);
              case 'SKIP':
                expect(controller.skip(), isTrue);
              case 'PREVIOUS':
                expect(controller.previous(), isTrue);
              case 'DONE':
                expect(controller.done(), isTrue);
            }

            await tester.pump();
            stepIndex++;
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(stepIndex, expectations.length);
    expect(find.text('Drawer is open'), findsNothing);
    expect(find.text('Dialog is open'), findsNothing);
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.step),
      equals(expectations.map((expectation) => expectation.step).toList()),
    );
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
      equals([
        _TourIndex.drawer.index.toDouble(),
        _TourIndex.drawerButton.index.toDouble(),
        _TourIndex.settingAction.index.toDouble(),
        _TourIndex.list.index.toDouble(),
        _TourIndex.firstItem.index.toDouble(),
        _TourIndex.item90.index.toDouble(),
        _TourIndex.dialogButton.index.toDouble(),
        _TourIndex.restartTourButton.index.toDouble(),
        _TourIndex.floatingButton.index.toDouble(),
      ]),
    );
    expect(
      collectedStates.whereType<TourActionEmitted>().map(
        (state) => state.action,
      ),
      equals([
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.next,
        TourAction.done,
      ]),
    );
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets('falls back to the next ordered step when nextStep times out', (
    tester,
  ) async {
    final controller = FeaturesTourController('TimeoutApp');
    final collectedStates = <TourState>[];

    await tester.pumpWidget(
      MaterialApp(home: _TimeoutHarness(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_TimeoutHarness));

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
            await tester.pump();

            if (index == _TimeoutStep.first.index.toDouble()) {
              expect(step, _TimeoutStep.first);
              expect(find.text('First intro'), findsOneWidget);
              expect(controller.next(), isTrue);
            } else if (index == _TimeoutStep.second.index.toDouble()) {
              expect(step, _TimeoutStep.second);
              expect(find.text('Second intro'), findsOneWidget);
              expect(controller.done(), isTrue);
            }
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.step),
      equals([_TimeoutStep.first, _TimeoutStep.second]),
    );
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
      equals([
        _TimeoutStep.first.index.toDouble(),
        _TimeoutStep.second.index.toDouble(),
      ]),
    );
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets('keeps the current step when previousStepTimeout times out', (
    tester,
  ) async {
    final controller = FeaturesTourController('PreviousTimeoutApp');
    final collectedStates = <TourState>[];
    var sawSecondStepTwice = false;

    await tester.pumpWidget(
      MaterialApp(home: _PreviousTimeoutHarness(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_PreviousTimeoutHarness));

    await tester.runAsync(() async {
      await controller.start(
        context,
        force: true,
        delay: Duration.zero,
        onStateChanged: (state) async {
          collectedStates.add(state);

          if (state case TourIntroducing(step: final step)) {
            await tester.pump();

            if (step == _PreviousTimeoutStep.first) {
              expect(step, _PreviousTimeoutStep.first);
              expect(find.text('First intro'), findsOneWidget);
              expect(controller.next(), isTrue);
            } else if (step == _PreviousTimeoutStep.second) {
              expect(step, _PreviousTimeoutStep.second);
              expect(find.text('Second intro'), findsOneWidget);

              if (!sawSecondStepTwice) {
                sawSecondStepTwice = true;
                expect(controller.previous(), isTrue);
              } else {
                expect(controller.done(), isTrue);
              }
            }
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(sawSecondStepTwice, isTrue);
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.step),
      equals([
        _PreviousTimeoutStep.first,
        _PreviousTimeoutStep.second,
        _PreviousTimeoutStep.second,
      ]),
    );
    expect(
      collectedStates.whereType<TourActionEmitted>().map(
        (state) => state.action,
      ),
      equals([TourAction.next, TourAction.previous, TourAction.done]),
    );
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets(
    'skips at a seeded random point and closes active surfaces (controller)',
    (tester) async {
      final controller = FeaturesTourController('App');
      final collectedStates = <TourState>[];
      final expectedSteps = <Enum>[
        _TourIndex.drawer,
        _TourIndex.drawerButton,
        _TourIndex.settingAction,
        _TourIndex.list,
        _TourIndex.firstItem,
        _TourIndex.item90,
        _TourIndex.dialogButton,
        _TourIndex.restartTourButton,
      ];
      final random = Random(20260415);

      final skipCandidates = <_TourExpectation>[
        const _TourExpectation(
          step: _TourIndex.drawerButton,
          actionLabel: 'SKIP',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.settingAction,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.list,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.firstItem,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.item90,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.dialogButton,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: true,
        ),
        const _TourExpectation(
          step: _TourIndex.restartTourButton,
          actionLabel: 'SKIP',
          drawerOpen: false,
          dialogOpen: false,
        ),
      ];

      final selectedExpectation =
          skipCandidates[random.nextInt(skipCandidates.length)];
      var skippedAtSelectedStep = false;
      var stepIndex = 0;

      await tester.pumpWidget(
        MaterialApp(home: _TourHarness(controller: controller)),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TourHarness));

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
              await tester.pump();

              expect(step, expectedSteps[stepIndex]);
              if (index == selectedExpectation.step.index) {
                skippedAtSelectedStep = true;
                // call controller.skip directly
                expect(controller.skip(), isTrue);
              } else {
                // advance normally
                expect(controller.next(), isTrue);
              }
              stepIndex++;
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(skippedAtSelectedStep, isTrue);
      expect(find.text('Drawer is open'), findsNothing);
      expect(find.text('Dialog is open'), findsNothing);
      expect(
        collectedStates.whereType<TourIntroducing>().map((state) => state.step),
        contains(selectedExpectation.step),
      );
      expect(
        collectedStates.whereType<TourIntroducing>().map(
          (state) => state.index,
        ),
        contains(selectedExpectation.step.index.toDouble()),
      );
      expect(
        collectedStates.whereType<TourActionEmitted>().last.action,
        TourAction.skip,
      );
      expect(collectedStates, contains(isA<TourCompleted>()));
    },
  );

  testWidgets('walks previous back through all widgets (controller)', (
    tester,
  ) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];
    final expectedSteps = <Enum>[
      _TourIndex.drawer,
      _TourIndex.drawerButton,
      _TourIndex.settingAction,
      _TourIndex.list,
      _TourIndex.firstItem,
      _TourIndex.item90,
      _TourIndex.dialogButton,
      _TourIndex.restartTourButton,
      _TourIndex.floatingButton,
      _TourIndex.restartTourButton,
      _TourIndex.dialogButton,
      _TourIndex.item90,
      _TourIndex.firstItem,
      _TourIndex.list,
      _TourIndex.settingAction,
      _TourIndex.drawerButton,
      _TourIndex.drawer,
    ];
    var stepIndex = 0;
    var rewinding = false;
    var reachedFirstStep = false;

    await tester.pumpWidget(
      MaterialApp(home: _TourHarness(controller: controller)),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(_TourHarness));

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
            await tester.pump();
            expect(step, expectedSteps[stepIndex]);

            if (!rewinding) {
              if (index == 8.0) {
                rewinding = true;
                expect(controller.previous(), isTrue);
              } else {
                expect(controller.next(), isTrue);
              }
              stepIndex++;
              return;
            }

            if (index == 0.0) {
              reachedFirstStep = true;
              expect(controller.previous(), isFalse);
              expect(controller.skip(), isTrue);
              stepIndex++;
              return;
            }

            expect(controller.previous(), isTrue);
            stepIndex++;
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(reachedFirstStep, isTrue);
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.step),
      equals([
        _TourIndex.drawer,
        _TourIndex.drawerButton,
        _TourIndex.settingAction,
        _TourIndex.list,
        _TourIndex.firstItem,
        _TourIndex.item90,
        _TourIndex.dialogButton,
        _TourIndex.restartTourButton,
        _TourIndex.floatingButton,
        _TourIndex.restartTourButton,
        _TourIndex.dialogButton,
        _TourIndex.item90,
        _TourIndex.firstItem,
        _TourIndex.list,
        _TourIndex.settingAction,
        _TourIndex.drawerButton,
        _TourIndex.drawer,
      ]),
    );
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
      equals([
        _TourIndex.drawer.index.toDouble(),
        _TourIndex.drawerButton.index.toDouble(),
        _TourIndex.settingAction.index.toDouble(),
        _TourIndex.list.index.toDouble(),
        _TourIndex.firstItem.index.toDouble(),
        _TourIndex.item90.index.toDouble(),
        _TourIndex.dialogButton.index.toDouble(),
        _TourIndex.restartTourButton.index.toDouble(),
        _TourIndex.floatingButton.index.toDouble(),
        _TourIndex.restartTourButton.index.toDouble(),
        _TourIndex.dialogButton.index.toDouble(),
        _TourIndex.item90.index.toDouble(),
        _TourIndex.firstItem.index.toDouble(),
        _TourIndex.list.index.toDouble(),
        _TourIndex.settingAction.index.toDouble(),
        _TourIndex.drawerButton.index.toDouble(),
        _TourIndex.drawer.index.toDouble(),
      ]),
    );
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets(
    'moves next and previous around drawer and dialog transitions (controller)',
    (tester) async {
      final controller = FeaturesTourController('App');
      final collectedStates = <TourState>[];
      final expectations = <_TourExpectation>[
        const _TourExpectation(
          step: _TourIndex.drawer,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.drawerButton,
          actionLabel: 'PREVIOUS',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.drawer,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.drawerButton,
          actionLabel: 'NEXT',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.settingAction,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.list,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.firstItem,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.item90,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.dialogButton,
          actionLabel: 'PREVIOUS',
          drawerOpen: false,
          dialogOpen: true,
        ),
        const _TourExpectation(
          step: _TourIndex.item90,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.dialogButton,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: true,
        ),
        const _TourExpectation(
          step: _TourIndex.restartTourButton,
          actionLabel: 'NEXT',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _TourExpectation(
          step: _TourIndex.floatingButton,
          actionLabel: 'DONE',
          drawerOpen: false,
          dialogOpen: false,
        ),
      ];

      var stepIndex = 0;

      await tester.pumpWidget(
        MaterialApp(home: _TourHarness(controller: controller)),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(_TourHarness));

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
              expect(stepIndex, lessThan(expectations.length));

              final expectation = expectations[stepIndex];
              expect(step, expectation.step);
              expect(index, expectation.step.index.toDouble());

              await tester.pump();

              switch (expectation.actionLabel) {
                case 'NEXT':
                  expect(controller.next(), isTrue);
                case 'SKIP':
                  expect(controller.skip(), isTrue);
                case 'PREVIOUS':
                  expect(controller.previous(), isTrue);
                case 'DONE':
                  expect(controller.done(), isTrue);
              }

              await tester.pump();
              stepIndex++;
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(stepIndex, expectations.length);
      expect(find.text('Drawer is open'), findsNothing);
      expect(find.text('Dialog is open'), findsNothing);
      expect(
        collectedStates.whereType<TourIntroducing>().map((state) => state.step),
        equals(expectations.map((expectation) => expectation.step).toList()),
      );
      expect(
        collectedStates.whereType<TourIntroducing>().map(
          (state) => state.index,
        ),
        equals([
          _TourIndex.drawer.index.toDouble(),
          _TourIndex.drawerButton.index.toDouble(),
          _TourIndex.drawer.index.toDouble(),
          _TourIndex.drawerButton.index.toDouble(),
          _TourIndex.settingAction.index.toDouble(),
          _TourIndex.list.index.toDouble(),
          _TourIndex.firstItem.index.toDouble(),
          _TourIndex.item90.index.toDouble(),
          _TourIndex.dialogButton.index.toDouble(),
          _TourIndex.item90.index.toDouble(),
          _TourIndex.dialogButton.index.toDouble(),
          _TourIndex.restartTourButton.index.toDouble(),
          _TourIndex.floatingButton.index.toDouble(),
        ]),
      );
      expect(
        collectedStates.whereType<TourActionEmitted>().map(
          (state) => state.action,
        ),
        equals([
          TourAction.next,
          TourAction.previous,
          TourAction.next,
          TourAction.next,
          TourAction.next,
          TourAction.next,
          TourAction.next,
          TourAction.next,
          TourAction.previous,
          TourAction.next,
          TourAction.next,
          TourAction.next,
          TourAction.done,
        ]),
      );
      expect(collectedStates, contains(isA<TourCompleted>()));
    },
  );
}

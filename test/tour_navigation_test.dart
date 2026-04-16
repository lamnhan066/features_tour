import 'dart:math';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TourIndex {
  static const drawer = 0.0;
  static const drawerButton = 1.0;
  static const settingAction = 2.0;
  static const list = 3.0;
  static const firstItem = 4.0;
  static const item90 = 5.0;
  static const dialogButton = 5.5;
  static const restartTourButton = 6.0;
  static const floatingButton = 7.0;
}

class _TourExpectation {
  const _TourExpectation({
    required this.index,
    required this.actionLabel,
    required this.drawerOpen,
    required this.dialogOpen,
  });

  final double index;
  final String actionLabel;
  final bool drawerOpen;
  final bool dialogOpen;
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
          index: _TourIndex.drawer,
          nextIndex: _TourIndex.drawerButton,
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
            index: _TourIndex.settingAction,
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
                    index: _TourIndex.list,
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
                    index: _TourIndex.firstItem,
                    nextIndex: _TourIndex.item90,
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
                        index: _TourIndex.item90,
                        nextIndex: _TourIndex.dialogButton,
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
                            index: _TourIndex.drawerButton,
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
                            index: _TourIndex.dialogButton,
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
                        index: _TourIndex.restartTourButton,
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
                        index: _TourIndex.floatingButton,
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
                    indexes: {
                      _TourIndex.restartTourButton,
                      _TourIndex.floatingButton,
                    },
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

  testWidgets('walks next through all widgets and completes', (tester) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];

    final expectations = <_TourExpectation>[
      const _TourExpectation(
        index: _TourIndex.drawer,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.drawerButton,
        actionLabel: 'NEXT',
        drawerOpen: true,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.settingAction,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.list,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.firstItem,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.item90,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.dialogButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: true,
      ),
      const _TourExpectation(
        index: _TourIndex.restartTourButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.floatingButton,
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

          if (state case TourIntroducing(index: final index)) {
            expect(stepIndex, lessThan(expectations.length));

            final expectation = expectations[stepIndex];
            expect(index, expectation.index);

            await tester.pump();
            expect(find.text(expectation.actionLabel), findsOneWidget);
            expect(
              find.text('Drawer is open'),
              expectation.drawerOpen ? findsOneWidget : findsNothing,
            );
            expect(
              find.text('Dialog is open'),
              expectation.dialogOpen ? findsOneWidget : findsNothing,
            );

            await tester.tap(find.text(expectation.actionLabel));
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
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
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

  testWidgets('skips at a seeded random point and closes active surfaces', (
    tester,
  ) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];
    final random = Random(20260415);

    final skipCandidates = <_TourExpectation>[
      const _TourExpectation(
        index: _TourIndex.drawerButton,
        actionLabel: 'SKIP',
        drawerOpen: true,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.settingAction,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.list,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.firstItem,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.item90,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.dialogButton,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: true,
      ),
      const _TourExpectation(
        index: _TourIndex.restartTourButton,
        actionLabel: 'SKIP',
        drawerOpen: false,
        dialogOpen: false,
      ),
    ];

    final selectedExpectation =
        skipCandidates[random.nextInt(skipCandidates.length)];
    var skippedAtSelectedStep = false;

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

          if (state case TourIntroducing(index: final index)) {
            await tester.pump();

            if (index == selectedExpectation.index) {
              skippedAtSelectedStep = true;
              expect(find.text('SKIP'), findsOneWidget);
              expect(
                find.text('Drawer is open'),
                selectedExpectation.drawerOpen ? findsOneWidget : findsNothing,
              );
              expect(
                find.text('Dialog is open'),
                selectedExpectation.dialogOpen ? findsOneWidget : findsNothing,
              );

              await tester.tap(find.text('SKIP'));
            } else {
              expect(find.text('NEXT'), findsOneWidget);
              await tester.tap(find.text('NEXT'));
            }
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(skippedAtSelectedStep, isTrue);
    expect(find.text('Drawer is open'), findsNothing);
    expect(find.text('Dialog is open'), findsNothing);
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
      contains(selectedExpectation.index),
    );
    expect(
      collectedStates.whereType<TourActionEmitted>().last.action,
      TourAction.skip,
    );
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets('walks previous back through all widgets', (tester) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];
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

          if (state case TourIntroducing(index: final index)) {
            await tester.pump();

            if (!rewinding) {
              if (index == _TourIndex.floatingButton) {
                rewinding = true;
                expect(find.text('PREVIOUS'), findsOneWidget);
                await tester.tap(find.text('PREVIOUS'));
              } else {
                expect(find.text('NEXT'), findsOneWidget);
                await tester.tap(find.text('NEXT'));
              }
              return;
            }

            if (index == _TourIndex.drawer) {
              reachedFirstStep = true;
              expect(controller.previous(), isFalse);
              await tester.tap(find.text('SKIP'));
              return;
            }

            expect(find.text('PREVIOUS'), findsOneWidget);
            await tester.tap(find.text('PREVIOUS'));
          }
        },
      );
    });

    await tester.pumpAndSettle();

    expect(reachedFirstStep, isTrue);
    expect(
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
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
    expect(collectedStates, contains(isA<TourCompleted>()));
  });

  testWidgets('moves next and previous around drawer and dialog transitions', (
    tester,
  ) async {
    final controller = FeaturesTourController('App');
    final collectedStates = <TourState>[];
    final expectations = <_TourExpectation>[
      const _TourExpectation(
        index: _TourIndex.drawer,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.drawerButton,
        actionLabel: 'PREVIOUS',
        drawerOpen: true,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.drawer,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.drawerButton,
        actionLabel: 'NEXT',
        drawerOpen: true,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.settingAction,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.list,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.firstItem,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.item90,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.dialogButton,
        actionLabel: 'PREVIOUS',
        drawerOpen: false,
        dialogOpen: true,
      ),
      const _TourExpectation(
        index: _TourIndex.item90,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.dialogButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: true,
      ),
      const _TourExpectation(
        index: _TourIndex.restartTourButton,
        actionLabel: 'NEXT',
        drawerOpen: false,
        dialogOpen: false,
      ),
      const _TourExpectation(
        index: _TourIndex.floatingButton,
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

          if (state case TourIntroducing(index: final index)) {
            expect(stepIndex, lessThan(expectations.length));

            final expectation = expectations[stepIndex];
            expect(index, expectation.index);

            await tester.pump();
            expect(find.text(expectation.actionLabel), findsOneWidget);
            expect(
              find.text('Drawer is open'),
              expectation.drawerOpen ? findsOneWidget : findsNothing,
            );
            expect(
              find.text('Dialog is open'),
              expectation.dialogOpen ? findsOneWidget : findsNothing,
            );

            await tester.tap(find.text(expectation.actionLabel));
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
      collectedStates.whereType<TourIntroducing>().map((state) => state.index),
      equals([
        _TourIndex.drawer,
        _TourIndex.drawerButton,
        _TourIndex.drawer,
        _TourIndex.drawerButton,
        _TourIndex.settingAction,
        _TourIndex.list,
        _TourIndex.firstItem,
        _TourIndex.item90,
        _TourIndex.dialogButton,
        _TourIndex.item90,
        _TourIndex.dialogButton,
        _TourIndex.restartTourButton,
        _TourIndex.floatingButton,
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
  });
}

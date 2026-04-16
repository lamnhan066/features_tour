import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lite_logger/lite_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum _DrawerDialogStep { drawer, drawerButton, settingAction }

class _StepExpectation {
  const _StepExpectation({
    required this.step,
    required this.actionLabel,
    required this.introLabel,
    required this.drawerOpen,
    required this.dialogOpen,
  });

  final _DrawerDialogStep step;
  final String actionLabel;
  final String introLabel;
  final bool drawerOpen;
  final bool dialogOpen;
}

class _DrawerDialogTourApp extends StatefulWidget {
  const _DrawerDialogTourApp({required this.controller});

  final FeaturesTourController controller;

  @override
  State<_DrawerDialogTourApp> createState() => _DrawerDialogTourAppState();
}

class _DrawerDialogTourAppState extends State<_DrawerDialogTourApp> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Dialog Tour'),
        leading: FeaturesTour(
          controller: widget.controller,
          step: _DrawerDialogStep.drawer,
          nextStep: _DrawerDialogStep.drawerButton,
          introduce: const Text('w1 intro'),
          onAfterAction: (result) {
            if (result == TourAction.next) {
              _openDrawer();
            }
          },
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _openDrawer,
            tooltip: 'Open Drawer',
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(child: Text('Main Screen')),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: IgnorePointer(
                ignoring: !_drawerOpen,
                child: Opacity(
                  opacity: _drawerOpen ? 1 : 0,
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
                              _drawerOpen
                                  ? 'Drawer is open'
                                  : 'Drawer is closed',
                            ),
                            const SizedBox(height: 12),
                            FeaturesTour(
                              controller: widget.controller,
                              step: _DrawerDialogStep.drawerButton,
                              nextStep: _DrawerDialogStep.settingAction,
                              introduce: const Text('w2 intro'),
                              onBeforeAction: (action) {
                                if (action == TourAction.previous) {
                                  _openDrawer();
                                }
                              },
                              onAfterAction: (result) {
                                _closeDrawer();

                                if (result == TourAction.next) {
                                  _showDialog();
                                }
                              },
                              child: ElevatedButton(
                                onPressed: _closeDrawer,
                                child: const Text('Drawer Step Button'),
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
          ),
          Positioned.fill(
            child: IgnorePointer(
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
                              _dialogOpen
                                  ? 'Dialog is open'
                                  : 'Dialog is closed',
                            ),
                            const SizedBox(height: 16),
                            const Text('Tour Dialog'),
                            const SizedBox(height: 16),
                            FeaturesTour(
                              controller: widget.controller,
                              step: _DrawerDialogStep.settingAction,
                              doneConfig: DoneConfig(enabled: true),
                              introduce: const Text('w3 intro'),
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
      doneConfig: DoneConfig(text: 'DONE'),
      skipConfig: SkipConfig(text: 'SKIP'),
    );
  });

  testWidgets(
    'navigates across the main screen, drawer, and dialog using TourAction hooks',
    (tester) async {
      final controller = FeaturesTourController('App');
      final collectedStates = <TourState>[];

      final stepExpectations = <_StepExpectation>[
        const _StepExpectation(
          step: _DrawerDialogStep.drawer,
          actionLabel: 'NEXT',
          introLabel: 'w1 intro',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawerButton,
          actionLabel: 'PREVIOUS',
          introLabel: 'w2 intro',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawer,
          actionLabel: 'NEXT',
          introLabel: 'w1 intro',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawerButton,
          actionLabel: 'NEXT',
          introLabel: 'w2 intro',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.settingAction,
          actionLabel: 'PREVIOUS',
          introLabel: 'w3 intro',
          drawerOpen: false,
          dialogOpen: true,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawerButton,
          actionLabel: 'PREVIOUS',
          introLabel: 'w2 intro',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawer,
          actionLabel: 'NEXT',
          introLabel: 'w1 intro',
          drawerOpen: false,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.drawerButton,
          actionLabel: 'NEXT',
          introLabel: 'w2 intro',
          drawerOpen: true,
          dialogOpen: false,
        ),
        const _StepExpectation(
          step: _DrawerDialogStep.settingAction,
          actionLabel: 'DONE',
          introLabel: 'w3 intro',
          drawerOpen: false,
          dialogOpen: true,
        ),
      ];

      var stepIndex = 0;

      await tester.pumpWidget(
        MaterialApp(home: _DrawerDialogTourApp(controller: controller)),
      );

      await tester.pumpAndSettle();
      final context = tester.element(find.byType(_DrawerDialogTourApp));

      await tester.runAsync(() async {
        await controller.start(
          context,
          force: true,
          delay: Duration.zero,
          onStateChanged: (state) async {
            collectedStates.add(state);

            if (state case TourIntroducing(step: final step)) {
              expect(stepIndex, lessThan(stepExpectations.length));

              final expectation = stepExpectations[stepIndex];
              expect(step, expectation.step);

              await tester.pump();

              expect(find.text(expectation.introLabel), findsOneWidget);
              expect(
                find.text('Drawer is open'),
                expectation.drawerOpen ? findsOneWidget : findsNothing,
              );
              expect(
                find.text('Dialog is open'),
                expectation.dialogOpen ? findsOneWidget : findsNothing,
              );
              expect(find.text(expectation.actionLabel), findsOneWidget);

              await tester.tap(find.text(expectation.actionLabel));
              await tester.pump();
              stepIndex++;
            }
          },
        );
      });

      await tester.pumpAndSettle();

      expect(stepIndex, stepExpectations.length);
      expect(find.text('Drawer is open'), findsNothing);
      expect(find.text('Dialog is open'), findsNothing);

      expect(
        collectedStates.whereType<TourIntroducing>().map((state) => state.step),
        equals([
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.settingAction,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.settingAction,
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
          TourAction.previous,
          TourAction.previous,
          TourAction.next,
          TourAction.next,
          TourAction.done,
        ]),
      );
      expect(
        collectedStates.whereType<TourBeforeActionCalled>().map(
          (state) => state.step,
        ),
        equals([
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawerButton,
        ]),
      );
      expect(
        collectedStates.whereType<TourBeforeActionCalled>().map(
          (state) => state.action,
        ),
        equals([
          TourAction.next,
          TourAction.next,
          TourAction.previous,
          TourAction.next,
        ]),
      );
      expect(
        collectedStates.whereType<TourAfterActionCalled>().map(
          (state) => state.step,
        ),
        equals([
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.settingAction,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.drawer,
          _DrawerDialogStep.drawerButton,
          _DrawerDialogStep.settingAction,
        ]),
      );
      expect(
        collectedStates.whereType<TourAfterActionCalled>().map(
          (state) => state.action,
        ),
        equals([
          TourAction.next,
          TourAction.previous,
          TourAction.next,
          TourAction.next,
          TourAction.previous,
          TourAction.previous,
          TourAction.next,
          TourAction.next,
          TourAction.done,
        ]),
      );
      expect(collectedStates, contains(isA<TourCompleted>()));
    },
  );
}

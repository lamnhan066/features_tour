import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    preDialogConfig: PreDialogConfig(
      enabled: true,
      title: 'Welcome to Features Tour',
      content: 'This tour will guide you through the main features of the app.',
      applyToAllCheckboxLabel: 'Apply to all pages',
      acceptButtonLabel: 'Start Tour',
      laterButtonLabel: 'Later',
      dismissButtonLabel: 'Dismiss',
    ),
    introduceConfig: RoundedRectIntroduceConfig(),
    childConfig: ChildConfig(isAnimateChild: false),
    skipConfig: SkipConfig(
      builder: (context, onPressed) => ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.skip_next),
        label: const Text('SKIP'),
      ),
    ),
    nextConfig: NextConfig(
      builder: (context, onPressed) => FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('NEXT'),
      ),
    ),
    doneConfig: DoneConfig(
      child: (onPressed) => FilledButton(
        onPressed: onPressed,
        child: const Text('DONE'),
      ),
    ),
    debugLog: true,
  );

  runApp(const ChangeableThemeMaterialApp());
}

abstract class MainTourIndex {
  static const drawer = 0.0;
  static const buttonOnDrawer = 1.0;
  static const settingAction = 2.0;
  static const list = 3.0;
  static const firstItem = 4.0;
  static const item90 = 5.0;
  static const dialogButton = 5.5;
  static const restartTourButton = 6.0;
  static const floatingButton = 7.0;
}

class ChangeableThemeMaterialApp extends StatefulWidget {
  const ChangeableThemeMaterialApp({super.key});

  @override
  State<ChangeableThemeMaterialApp> createState() =>
      _ChangeableThemeMaterialAppState();
}

class _ChangeableThemeMaterialAppState
    extends State<ChangeableThemeMaterialApp> {
  bool isDark = false;

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Features Tour Example',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final tourController = FeaturesTourController('App');
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    tourController.start(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final changeableState =
        context.findAncestorStateOfType<_ChangeableThemeMaterialAppState>()!;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('App'),
        leading: FeaturesTour(
          controller: tourController,
          index: MainTourIndex.drawer,
          nextIndex: MainTourIndex.buttonOnDrawer,
          onAfterIntroduce: (result) {
            if (result != IntroduceResult.next &&
                result != IntroduceResult.done) {
              return;
            }

            scaffoldKey.currentState?.openDrawer();
          },
          introduce: const Text('Tap here to open the drawer'),
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        actions: [
          FeaturesTour(
            controller: tourController,
            index: MainTourIndex.settingAction,
            introduce: const Text(
                'Tap here to change the brightness and reset the tour'),
            child: IconButton(
              icon: changeableState.isDark
                  ? const Icon(Icons.dark_mode)
                  : const Icon(Icons.light_mode),
              onPressed: () async {
                changeableState.toggleTheme();
                tourController.start(context, force: true);
              },
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Center(
          child: FeaturesTour(
            controller: tourController,
            index: MainTourIndex.buttonOnDrawer,
            introduce: const Text('Tap here to close the drawer'),
            onAfterIntroduce: (result) {
              if (result case IntroduceResult.next || IntroduceResult.done) {
                scaffoldKey.currentState?.closeDrawer();
              }
            },
            child: ElevatedButton(
              child: const Text('Close Drawer'),
              onPressed: () {
                scaffoldKey.currentState?.closeDrawer();
              },
            ),
          ),
        ),
      ),
      body: FeaturesTour(
        controller: tourController,
        index: MainTourIndex.list,
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
                color: ColorScheme.of(context).primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: introduce,
            );
          },
          quadrantAlignment: QuadrantAlignment.inside,
        ),
        childConfig: ChildConfig(
          enableAnimation: false,
        ),
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeaturesTour(
                      controller: tourController,
                      index: MainTourIndex.firstItem,
                      nextIndex: MainTourIndex.item90,
                      introduce: const Text('This is the item 0'),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('Item 0'),
                      ),
                    ),
                    for (var index = 1; index <= 100; index++)
                      FeaturesTour(
                        enabled: index == 95,
                        controller: tourController,
                        index: MainTourIndex.item90,
                        nextIndex: MainTourIndex.dialogButton,
                        introduce: Text('This is the item $index'),
                        onBeforeIntroduce: () async {
                          // Scroll to the last item when the first item is tapped
                          await scrollController.animateTo(
                            scrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        onAfterIntroduce: (introduceResult) async {
                          if (introduceResult
                              case IntroduceResult.next ||
                                  IntroduceResult.done) {
                            // Scroll to the first item when item 90 is tapped
                            await scrollController.animateTo(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );

                            // Show a dialog after item 90 is tapped
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('A Dialog'),
                                    actions: [
                                      FeaturesTour(
                                        controller: tourController,
                                        index: MainTourIndex.dialogButton,
                                        introduce: const Text(
                                          'Tap here to close the dialog',
                                        ),
                                        onAfterIntroduce: (result) {
                                          if (introduceResult !=
                                                  IntroduceResult.next &&
                                              introduceResult !=
                                                  IntroduceResult.done) {
                                            return;
                                          }

                                          Navigator.of(context).pop();
                                        },
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ok'),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Item $index'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FeaturesTour(
                          controller: tourController,
                          index: MainTourIndex.restartTourButton,
                          introduce:
                              const Text('Tap here to run the tour again'),
                          childConfig: ChildConfig(
                            shapeBorder: const CircleBorder(),
                            borderSizeInflate: 10.0,
                          ),
                          child: FloatingActionButton(
                            onPressed: () {
                              tourController.start(
                                context,
                                force: true,
                                preDialogConfig:
                                    PreDialogConfig(enabled: false),
                              );
                            },
                            child: const Icon(Icons.restart_alt_rounded),
                          ),
                        ),
                        FeaturesTour(
                          controller: tourController,
                          index: MainTourIndex.floatingButton,
                          introduce: const Text('Tap here to add a new item'),
                          childConfig: ChildConfig(
                            shapeBorder: const CircleBorder(),
                            borderSizeInflate: 10.0,
                          ),
                          child: FloatingActionButton(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    FeaturesTourPadding(
                      controller: tourController,
                      indexes: {
                        MainTourIndex.floatingButton,
                        MainTourIndex.restartTourButton
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

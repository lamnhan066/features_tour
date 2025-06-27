import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    force: true,
    predialogConfig: PredialogConfig(
      enabled: true,
    ),
    childConfig: ChildConfig(isAnimateChild: false),
    nextConfig: NextConfig(
      child: (onPressed) => FilledButton(
        onPressed: onPressed,
        child: const Text('NEXT'),
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

  runApp(MaterialApp(
    home: const App(),
    theme: ThemeData.light(),
  ));
}

abstract class MainTourIndex {
  static const drawer = 0.0;
  static const buttonOnDrawer = 1.0;
  static const settingAction = 2.0;
  static const list = 3.0;
  static const firstItem = 4.0;
  static const item90 = 5.0;
  static const dialogButton = 5.5;
  static const floatingButton = 6.0;
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
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('App'),
        leading: FeaturesTour(
          controller: tourController,
          index: MainTourIndex.drawer,
          waitForIndex: MainTourIndex.buttonOnDrawer,
          introduce: const Text('Tap here to open the drawer'),
          onPressed: () async {
            scaffoldKey.currentState?.openDrawer();
          },
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
            introduce: const Text('Tap here to open the settings'),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
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
            onPressed: () {
              scaffoldKey.currentState?.closeDrawer();
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
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        introduceConfig: IntroduceConfig(
          quadrantAlignment: QuadrantAlignment.inside,
        ),
        childConfig: ChildConfig(
          enableAnimation: false,
        ),
        child: SingleChildScrollView(
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
                  waitForIndex: MainTourIndex.item90,
                  introduce: const Text('This is item 0'),
                  onPressed: () async {
                    // Scroll to the last item when the first item is tapped
                    await scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Item 0'),
                  ),
                ),
                for (var index = 1; index <= 100; index++)
                  FeaturesTour(
                    enabled: index == 90,
                    controller: tourController,
                    index: MainTourIndex.item90,
                    waitForIndex: MainTourIndex.dialogButton,
                    introduce: Text('This is item $index'),
                    onPressed: () async {
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
                                  onPressed: () {
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
      ),
      floatingActionButton: FeaturesTour(
        controller: tourController,
        index: MainTourIndex.floatingButton,
        introduce: const Text('Tap here to add a new item'),
        doneConfig: DoneConfig(alignment: Alignment.bottomLeft),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

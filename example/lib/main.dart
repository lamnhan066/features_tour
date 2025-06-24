import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/main_tour_index.dart';
import 'package:flutter/material.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    force: true,
    predialogConfig: PredialogConfig(
      enabled: true,
    ),
    childConfig: ChildConfig(isAnimateChild: false),
    debugLog: true,
  );

  runApp(MaterialApp(
    home: const App(),
    theme: ThemeData.light(),
  ));
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
          index: MainTourIndex.drawer.tourIndex,
          waitForIndex: MainTourIndex.buttonOnDrawer.tourIndex,
          introduce: const Text('This is the leading icon'),
          onPressed: () {
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
            index: MainTourIndex.settingAction.tourIndex,
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
            index: MainTourIndex.buttonOnDrawer.tourIndex,
            introduce: const Text('This text will be shown on the Drawer'),
            childConfig: ChildConfig(
              isAnimateChild: true,
            ),
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
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FeaturesTour(
              controller: tourController,
              index: MainTourIndex.firstItem.tourIndex,
              waitForIndex: MainTourIndex.item90.tourIndex,
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
                padding: EdgeInsets.all(8.0),
                child: Text('Item 0'),
              ),
            ),
            for (int i = 1; i <= 100; i++)
              FeaturesTour(
                enabled: i == 90,
                controller: tourController,
                index: MainTourIndex.item90.tourIndex,
                introduce: const Text('This is item 90'),
                onPressed: () async {
                  // Scroll to the first item when item 90 is tapped
                  await scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Item $i'),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FeaturesTour(
        controller: tourController,
        index: MainTourIndex.floatingButton.tourIndex,
        introduce: const Text('This is the floating action button'),
        doneConfig: DoneConfig(alignment: Alignment.bottomLeft),
        child: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

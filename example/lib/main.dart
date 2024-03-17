import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/main_drawer.dart';
import 'package:flutter/material.dart';

import 'next_page.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    force: true,
    predialogConfig: PredialogConfig.copyWith(
      enabled: true,
    ),
    debugLog: true,
  );

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final tourController = FeaturesTourController('MyApp');

  @override
  void initState() {
    tourController.start(
      /// Context of the current Page
      context,

      /// Delay before starting the tour
      delay: Duration.zero,

      /// If true, it will force to start the tour even already shown.
      /// If false, it will force not to start the tour.
      /// Default is null (depends on the global config).
      // force: true,

      /// Show specific pre-dialog for this Page
      predialogConfig: PredialogConfig.copyWith(),
    );

    super.initState();
  }

  void showDialogOnPressed() {
    Future.delayed(const Duration(seconds: 1)).then((timer) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Show this dialog'),
            content: FeaturesTour(
              controller: tourController,
              index: 1.1,
              introduce: const Center(
                child: Text(
                  'This tour will wait for the dialog to be shown',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              childConfig: ChildConfig.copyWith(backgroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text('This is a introduction field'),
            ),
          );
        },
      );
    });
  }

  void showDialogTimeoutOnPressed() {
    Future.delayed(const Duration(seconds: 4)).then((timer) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Show this dialog'),
            content: FeaturesTour(
              controller: tourController,
              index: 3.1,
              introduce: const Center(
                child: Text(
                  'This tour will wait for the dialog to be shown',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              childConfig: ChildConfig.copyWith(backgroundColor: Colors.white),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                  'This widget will be not introduced because of the timeout'),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      drawer: const MainDrawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FeaturesTour(
            controller: tourController,
            index: 1,
            waitForIndex: 1.1,
            onPressed: showDialogOnPressed,
            introduce: const Text(
              'This button will be shown after Button 1',
              style: TextStyle(color: Colors.white),
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: showDialogOnPressed,
                child: const Text('Show the dialog after 1 second'),
              ),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 0,
            introduce: const Text(
              'This button will show first',
              style: TextStyle(color: Colors.white),
            ),
            introduceConfig: IntroduceConfig.copyWith(
                // quadrantAlignment: QuadrantAlignment.bottom,
                ),
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button 1'),
              ),
            ),
            onPressed: () async {},
          ),
          FeaturesTour(
            controller: tourController,
            index: 2,
            introduce: const Text(
              'This text will be shown inside the TextField',
              style: TextStyle(color: Colors.black),
            ),
            introduceConfig: IntroduceConfig.copyWith(
              quadrantAlignment: QuadrantAlignment.inside,
            ),
            childConfig: ChildConfig.copyWith(
              backgroundColor: Colors.white,
              zoomScale: 1.05,
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 100,
              child: const TextField(
                maxLines: null,
                expands: true,
              ),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 2.5,
            childConfig: ChildConfig.copyWith(
              child: (child) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Show dialog timeout (4 seconds)'),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Button 4'),
                    ),
                  ),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FeaturesTour(
                  controller: tourController,
                  index: 3,
                  waitForIndex: 3.1,
                  introduce: const Text(
                    'This is the Button 3',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: showDialogTimeoutOnPressed,
                  nextConfig: NextConfig.copyWith(
                    alignment: Alignment.centerRight,
                  ),
                  skipConfig: SkipConfig.copyWith(
                    alignment: Alignment.centerLeft,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Show dialog timeout (4 seconds)'),
                    ),
                  ),
                ),
                FeaturesTour(
                  controller: tourController,
                  index: 4,
                  introduce: const Text(
                    'This is the Button 4',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {},
                  nextConfig: NextConfig.copyWith(
                    alignment: Alignment.centerRight,
                  ),
                  skipConfig: SkipConfig.copyWith(
                    alignment: Alignment.centerLeft,
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Button 4'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FeaturesTour(
        controller: tourController,
        index: 5,
        introduce: const Text(
          'This is the last Button. Press to navigate to the NextPage >>',
          style: TextStyle(color: Colors.white),
        ),
        skipConfig: SkipConfig.copyWith(
          enabled: false,
        ),
        nextConfig: NextConfig.copyWith(
          enabled: false,
        ),
        doneConfig: DoneConfig.copyWith(
          enabled: false,
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NextPage()));
        },
        child: FloatingActionButton(
          heroTag: UniqueKey(),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NextPage()));
          },
        ),
      ),
    );
  }
}

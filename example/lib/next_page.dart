import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/third_page.dart';
import 'package:flutter/material.dart';

import 'main_drawer.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final tourController = FeaturesTourController('SecondPage');

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
      predialogConfig: PredialogConfig(),
    );

    super.initState();
  }

  void showDialogOnPressed() {
    Future.delayed(const Duration(seconds: 1)).then((timer) {
      if (mounted) {
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
                onPressed: () => Navigator.pop(context),
                child: const Text('This is a introduction field'),
              ),
            );
          },
        );
      }
    });
  }

  void showDialogTimeoutOnPressed() {
    Future.delayed(const Duration(seconds: 4)).then((timer) {
      if (mounted) {
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                    'This widget will not be shown after the `Show dialog timeout (4 seconds)` '
                    'even when the `waitForIndex` is set because the `waitForTimeout` is reached.'),
              ),
            );
          },
        );
      }
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
          Center(
            child: FeaturesTour(
              controller: tourController,
              index: 1,
              waitForIndex: 1.1,
              onPressed: showDialogOnPressed,
              introduce: const Text('This button will be shown after Button 1'),
              child: ElevatedButton(
                onPressed: showDialogOnPressed,
                child: const Text('Show the dialog after 1 second'),
              ),
            ),
          ),
          Center(
            child: FeaturesTour(
              controller: tourController,
              index: 0,
              introduce: const Text('This button will show first'),
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button 1'),
              ),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 2,
            introduce: const Text(
              'This text will be shown inside the TextField',
            ),
            introduceConfig: IntroduceConfig(
              quadrantAlignment: QuadrantAlignment.inside,
              applyDarkTheme: false,
            ),
            childConfig: ChildConfig(
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
            introduce: const Text(
              'FeaturesTours inside a FeaturesTour',
            ),
            childConfig: ChildConfig(
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
                  waitForTimeout: const Duration(seconds: 3),
                  introduce: const Text('This is the Button 3'),
                  onPressed: showDialogTimeoutOnPressed,
                  nextConfig: NextConfig(
                    alignment: Alignment.centerRight,
                  ),
                  skipConfig: SkipConfig(
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
                  introduce: const Text('This is the Button 4'),
                  onPressed: () async {},
                  nextConfig: NextConfig(
                    alignment: Alignment.centerRight,
                  ),
                  skipConfig: SkipConfig(
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
          'This is the last Button. Press to navigate to the Third Page >>',
        ),
        skipConfig: SkipConfig(
          enabled: false,
        ),
        nextConfig: NextConfig(
          enabled: false,
        ),
        doneConfig: DoneConfig(
          enabled: false,
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ThirdPage()));
        },
        child: FloatingActionButton(
          heroTag: UniqueKey(),
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ThirdPage()));
          },
        ),
      ),
    );
  }
}

import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

import 'next_page.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    force: true,
    predialogConfig: PredialogConfig(
      enabled: true,
    ),
    debugLog: true,
  );

  runApp(const MaterialApp(home: App()));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final tourController = FeaturesTourController('App');

  @override
  void initState() {
    tourController.start(context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FeaturesTour(
            controller: tourController,
            index: 0,
            introduce: const Text(
              'This is TextButton 1',
              style: TextStyle(color: Colors.white),
            ),
            nextConfig: NextConfig(
              child: (onPressed) {
                return ElevatedButton(
                  onPressed: onPressed,
                  child: const Text('Modified Next'),
                );
              },
            ),
            childConfig: ChildConfig(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 1'),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FeaturesTour(
              controller: tourController,
              index: 1,
              introduce: const Text(
                'This is TextButton 2',
                style: TextStyle(color: Colors.white),
              ),
              childConfig: ChildConfig(
                backgroundColor: Colors.white,
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text('TextButton 2'),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FeaturesTour(
              controller: tourController,
              index: 2,
              introduce: const Text(
                'This is TextButton 3',
                style: TextStyle(color: Colors.white),
              ),
              childConfig: ChildConfig(
                backgroundColor: Colors.white,
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text('TextButton 3'),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: FeaturesTour(
                controller: tourController,
                index: 3,
                introduce: const Text(
                  'Go to the Second Page (A more complicated tour)',
                  style: TextStyle(color: Colors.white),
                ),
                childConfig: ChildConfig(
                  backgroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SecondPage()));
                },
                doneConfig: DoneConfig(text: 'Second Page'),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SecondPage()));
                  },
                  child: const Text('Second Page'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

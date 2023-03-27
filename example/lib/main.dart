import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

import 'next_page.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    skipConfig: SkipConfig.global.copyWith(
      text: 'SKIP >>>',
    ),
    nextConfig: NextConfig.global.copyWith(
      text: 'NEXT >>',
    ),
    introdureConfig: IntrodureConfig.global.copyWith(
      backgroundColor: Colors.black,
    ),
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
    tourController.start(context: context);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      drawer: const Drawer(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FeaturesTour(
            controller: tourController,
            index: 1,
            introdure: const Text(
              'This button will be shown after Button 1',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
            ),
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Button 2'),
              ),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 0,
            introdure: const Text(
              'This button will show first',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
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
            // key: GlobalKey(),
            index: 2,
            introdure: const Text(
              'This is a TextField\nLine 2\nLine 3',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.top,
            ),
            childConfig: const ChildConfig(
              backgroundColor: Colors.white,
            ),
            child: const Center(child: TextField()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FeaturesTour(
                controller: tourController,
                index: 3,
                introdure: const Text(
                  'This is the Button 3',
                  style: TextStyle(color: Colors.white),
                ),
                introdureConfig: const IntrodureConfig(
                  alignment: Alignment.bottomLeft,
                  quadrantAlignment: QuadrantAlignment.top,
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button 3'),
                  ),
                ),
              ),
              FeaturesTour(
                controller: tourController,
                index: 4,
                introdure: const Text(
                  'This is the Button 4',
                  style: TextStyle(color: Colors.white),
                ),
                introdureConfig: const IntrodureConfig(
                  alignment: Alignment.bottomRight,
                  quadrantAlignment: QuadrantAlignment.top,
                ),
                onPressed: () async {},
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Button 4'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FeaturesTour(
        controller: tourController,
        index: 5,
        introdure: const Text(
          'This is the last Button. Press to navigate to the NextPage >>',
          style: TextStyle(color: Colors.white),
        ),
        introdureConfig: const IntrodureConfig(
          alignment: Alignment.bottomRight,
          quadrantAlignment: QuadrantAlignment.top,
        ),
        skipConfig: const SkipConfig(
          enabled: false,
        ),
        nextConfig: const NextConfig(
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

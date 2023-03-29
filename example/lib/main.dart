import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

import 'next_page.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    force: true,
    skipConfig: SkipConfig.copyWith(
      text: 'SKIP >>>',
    ),
    nextConfig: NextConfig.copyWith(
      text: 'NEXT >>',
    ),
    introduceConfig: IntroduceConfig.copyWith(
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
            introduce: const Text(
              'This button will be shown after Button 1',
              style: TextStyle(color: Colors.white),
            ),
            introduceConfig: const IntroduceConfig(
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
            introduce: const Text(
              'This button will show first',
              style: TextStyle(color: Colors.white),
            ),
            introduceConfig: const IntroduceConfig(
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
            introduce: const Text(
              'This text will be shown inside the TextField',
              style: TextStyle(color: Colors.black),
            ),
            introduceConfig: const IntroduceConfig(
              quadrantAlignment: QuadrantAlignment.inside,
            ),
            childConfig: const ChildConfig(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FeaturesTour(
                controller: tourController,
                index: 3,
                introduce: const Text(
                  'This is the Button 3',
                  style: TextStyle(color: Colors.white),
                ),
                introduceConfig: const IntroduceConfig(
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
                introduce: const Text(
                  'This is the Button 4',
                  style: TextStyle(color: Colors.white),
                ),
                introduceConfig: const IntroduceConfig(
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
        introduce: const Text(
          'This is the last Button. Press to navigate to the NextPage >>',
          style: TextStyle(color: Colors.white),
        ),
        introduceConfig: const IntroduceConfig(
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

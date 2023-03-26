import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/next_page.dart';
import 'package:flutter/material.dart';

void main() {
  FeaturesTour.setGlobalConfig(
    childConfig: ChildConfig.global.copyWith(
      backgroundColor: Colors.white,
    ),
    skipConfig: SkipConfig.global.copyWith(
      text: 'SKIP >>>',
    ),
    nextConfig: NextConfig.global.copyWith(text: 'NEXT >>'),
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
  @override
  void initState() {
    FeaturesTour.setPageName('MyApp');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeaturesTour.start(context: context, pageName: 'MyApp', isDebug: true)
          .then((value) => print('Completed'));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FeaturesTour(
            // enabled: false,
            key: GlobalKey(),
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
            // enabled: false,
            key: GlobalKey(),
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
            key: GlobalKey(),
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
                // enabled: false,
                key: GlobalKey(),
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
                // enabled: false,
                key: GlobalKey(),
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
        key: GlobalKey(),
        index: 5,
        introdure: const Text(
          'This is the last Button. Press to navigate to the NextPage >>',
          style: TextStyle(color: Colors.white),
        ),
        introdureConfig: const IntrodureConfig(
          alignment: Alignment.bottomRight,
          quadrantAlignment: QuadrantAlignment.top,
        ),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const NextPage()));
          },
        ),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NextPage()));
        },
      ),
    );
  }
}

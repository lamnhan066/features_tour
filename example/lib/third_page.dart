import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  final tourController = FeaturesTourController('ThirdPage');

  @override
  void initState() {
    // FeaturesTour.setPageName('ThirdPage');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      tourController.start(context: context, isDebug: true);
    });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Column(
        children: [
          FeaturesTour(
            controller: tourController,
            index: 0,
            introdure: const Text(
              'This is TextButton 1',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
            ),
            childConfig: const ChildConfig(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 1'),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 1,
            introdure: const Text(
              'This is TextButton 2',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
            ),
            childConfig: const ChildConfig(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 2'),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 2,
            introdure: const Text(
              'This is the last Button. Choose Finish to comback to the Home page.',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
            ),
            childConfig: const ChildConfig(
              backgroundColor: Colors.white,
            ),
            nextConfig: const NextConfig(text: 'Finish'),
            skipConfig: const SkipConfig(enabled: false),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 3'),
            ),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
    );
  }
}

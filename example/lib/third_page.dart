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
    tourController.start(context);

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
            introduce: const Text(
              'This is TextButton 1',
              style: TextStyle(color: Colors.white),
            ),
            // introduceConfig: IntroduceConfig.copyWith(
            // quadrantAlignment: QuadrantAlignment.bottom,
            // ),
            childConfig: ChildConfig.copyWith(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 1'),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            introduce: const Text(
              'This is TextButton 2',
              style: TextStyle(color: Colors.white),
            ),
            // introduceConfig: IntroduceConfig.copyWith(
            // quadrantAlignment: QuadrantAlignment.bottom,
            // ),
            childConfig: ChildConfig.copyWith(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 2'),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            introduce: const Text(
              'This is the last Button. Choose Finish to comback to the Home page.',
              style: TextStyle(color: Colors.white),
            ),
            // introduceConfig: IntroduceConfig.copyWith(
            // quadrantAlignment: QuadrantAlignment.bottom,
            // ),
            childConfig: ChildConfig.copyWith(
              backgroundColor: Colors.white,
            ),
            nextConfig: NextConfig.copyWith(text: 'Finish'),
            skipConfig: SkipConfig.copyWith(enabled: false),
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

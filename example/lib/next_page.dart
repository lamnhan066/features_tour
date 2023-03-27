import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/third_page.dart';
import 'package:flutter/material.dart';

class NextPage extends StatefulWidget {
  const NextPage({Key? key}) : super(key: key);

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  final tourController = FeaturesTourController('NextPage');

  @override
  void initState() {
    tourController.start(context: context);

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
              'This is TextButton 3',
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
              child: const Text('TextButton 3'),
            ),
          ),
          FeaturesTour(
            controller: tourController,
            index: 3,
            introdure: const Text(
              'Go to ThirdPage',
              style: TextStyle(color: Colors.white),
            ),
            introdureConfig: const IntrodureConfig(
              quadrantAlignment: QuadrantAlignment.bottom,
            ),
            childConfig: const ChildConfig(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const ThirdPage()));
              },
              child: const Text('TextButton 3'),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const ThirdPage()));
            },
          ),
        ],
      ),
    );
  }
}

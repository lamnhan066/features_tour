import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({Key? key}) : super(key: key);

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  void initState() {
    FeaturesTour.setPageName('ThirdPage');

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeaturesTour.start(
        context: context,
        pageName: 'ThirdPage',
        isDebug: true,
      );
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
            key: GlobalKey(),
            index: 0,
            name: 'nextpage0',
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
            key: GlobalKey(),
            index: 1,
            name: 'nextpage1',
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
            key: GlobalKey(),
            index: 2,
            name: 'nextpage2',
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
        ],
      ),
    );
  }
}

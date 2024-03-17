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
            index: 1,
            introduce: const Text(
              'This is TextButton 1',
              style: TextStyle(color: Colors.white),
            ),
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
            index: 2,
            introduce: const Text(
              'This is TextButton 2',
              style: TextStyle(color: Colors.white),
            ),
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
            index: 3,
            waitForIndex: 4,
            waitForTimeout: const Duration(seconds: 10),
            introduce: const Text(
              'There is another button that will appear in 5 seconds',
              style: TextStyle(color: Colors.white),
            ),
            childConfig: ChildConfig.copyWith(
              backgroundColor: Colors.white,
            ),
            child: TextButton(
              onPressed: () {},
              child: const Text('TextButton 3'),
            ),
          ),
          FutureBuilder<bool>(future: () async {
            await Future.delayed(const Duration(seconds: 5));
            return true;
          }(), builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }
            return FeaturesTour(
              controller: tourController,
              index: 4,
              introduce: const Text(
                'This is the last Button. Choose Done to comback to the Home page.',
                style: TextStyle(color: Colors.white),
              ),
              childConfig: ChildConfig.copyWith(
                backgroundColor: Colors.white,
              ),
              child: TextButton(
                onPressed: () {},
                child: const Text('TextButton 4'),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            );
          }),
        ],
      ),
    );
  }
}

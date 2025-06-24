import 'package:features_tour/features_tour.dart';
import 'package:features_tour_example/main_tour_index.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final tourController = FeaturesTourController('MainDrawer');

  @override
  void initState() {
    tourController.start(
      context,
      predialogConfig: PredialogConfig(enabled: false),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: FeaturesTour(
          controller: tourController,
          index: MainTourIndex.buttonOnDrawer.tourIndex,
          introduce: const Text('This text will be shown on the Drawer'),
          childConfig: ChildConfig(
            isAnimateChild: true,
          ),
          onPressed: () {
            Scaffold.of(context).closeDrawer();
          },
          child: ElevatedButton(
            child: const Text('Close Drawer'),
            onPressed: () {
              Scaffold.of(context).closeDrawer();
            },
          ),
        ),
      ),
    );
  }
}

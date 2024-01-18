import 'package:features_tour/features_tour.dart';
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
      predialogConfig: PredialogConfig.copyWith(enabled: false),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Center(
        child: FeaturesTour(
          controller: tourController,
          index: 0,
          introduce: const Text(
            'This text will be shown on the Drawer',
            style: TextStyle(color: Colors.white),
          ),
          childConfig: ChildConfig.copyWith(
            isAnimateChild: true,
          ),
          child: ElevatedButton(
            child: const Text('On the Drawer'),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

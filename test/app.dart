import 'package:features_tour/src/features_tour.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({required this.tours, super.key});

  final List<FeaturesTour> tours;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [...tours],
      ),
    );
  }
}

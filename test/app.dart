import 'package:features_tour/src/features_tour.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key, required this.tours});

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

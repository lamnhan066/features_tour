import 'package:flutter/material.dart';

class UnfeaturesTour extends InheritedWidget {
  const UnfeaturesTour({
    required super.child, super.key,
  });

  static bool isUnfeaturesTour(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<UnfeaturesTour>() !=
        null;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

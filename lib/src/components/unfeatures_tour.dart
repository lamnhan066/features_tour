import 'package:flutter/material.dart';

class UnfeaturesTour extends InheritedWidget {
  const UnfeaturesTour({
    super.key,
    required super.child,
  });

  static bool isUnfeaturesTour(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<UnfeaturesTour>() !=
        null;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

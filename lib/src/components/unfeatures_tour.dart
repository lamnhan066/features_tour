import 'package:material_ui/material_ui.dart';

/// An inherited widget that indicates that the current context is within an
/// unfeatured tour.
class UnfeaturesTour extends InheritedWidget {
  /// Creates an [UnfeaturesTour] widget.
  const new({required super.child, super.key});

  /// Checks if the current [context] is within an [UnfeaturesTour].
  static bool isUnfeaturesTour(BuildContext? context) {
    return context?.dependOnInheritedWidgetOfExactType<UnfeaturesTour>() !=
        null;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

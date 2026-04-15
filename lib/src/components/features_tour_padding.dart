part of '../features_tour.dart';

/// A widget that adds padding around its child when the current tour index matches any of the specified indexes.
/// This is useful for creating space around features during a guided tour.
/// The padding is animated for a smooth transition.
class FeaturesTourPadding extends StatelessWidget {
  /// Creates a FeaturesTourPadding widget.
  ///
  /// [indexes] is a set of tour indexes at which the padding should be applied.
  /// [padding] is the amount of padding to apply (default is 30 pixels vertically).
  /// [child] is the widget to which the padding will be applied.
  /// [animationDuration] is the duration of the padding animation (default is 300 milliseconds).
  /// [animationCurve] is the curve of the padding animation (default is Curves.easeInOut).
  const FeaturesTourPadding({
    required this.controller,
    this.indexes,
    this.steps,
    this.padding = const EdgeInsets.symmetric(vertical: 30),
    this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    super.key,
  }) : assert(
         indexes != null || steps != null,
         'Either indexes or steps must be provided.',
       );

  /// The controller that manages the tour state.
  final FeaturesTourController controller;

  /// Updates the padding of all registered FeaturesTourPadding widgets based on the current tour index.
  final Set<double>? indexes;

  /// Updates the padding of all registered FeaturesTourPadding widgets based on the current tour step.
  final Set<Enum>? steps;

  /// The amount of padding to apply (default is 30 pixels vertically).
  final EdgeInsetsGeometry padding;

  /// The widget to which the padding will be applied.
  final Widget? child;

  /// The duration of the padding animation (default is 300 milliseconds).
  final Duration animationDuration;

  /// The curve of the padding animation (default is Curves.easeInOut).
  final Curve animationCurve;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller._introducingIndex,
      builder: (context, value, _) {
        return AnimatedPadding(
          duration: animationDuration,
          curve: animationCurve,
          padding:
              value != null &&
                      ((indexes != null && indexes!.contains(value)) ||
                          (steps != null &&
                              steps!.any((e) => e.index.toDouble() == value)))
                  ? padding
                  : EdgeInsets.zero,
          child: child,
        );
      },
    );
  }
}

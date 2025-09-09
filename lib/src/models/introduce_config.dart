import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

/// Configuration for the `introduce` widget in the Features Tour.
class IntroduceConfig {
  /// Creates a new IntroduceConfig based on [global] values.
  factory IntroduceConfig({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
    bool? useRootOverlay,
  }) {
    return global.copyWith(
      backgroundColor: backgroundColor,
      padding: padding,
      alignment: alignment,
      quadrantAlignment: quadrantAlignment,
      useRootOverlay: useRootOverlay,
    );
  }

  const IntroduceConfig._({
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20),
    this.quadrantAlignment,
    this.alignment,
    this.useRootOverlay = false,
  });

  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

  /// The color of the background for the `introduce` widget.
  final Color? backgroundColor;

  /// The padding around the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// The quadrant rectangle for positioning the `introduce` widget.
  final QuadrantAlignment? quadrantAlignment;

  /// The alignment of the `introduce` widget within the specified `quadrantAlignment`.
  /// This value automatically aligns the widget depending on the chosen
  /// `quadrantAlignment`. It aims to keep the widget as close as possible to
  /// the other elements.
  final Alignment? alignment;

  /// If `useRootOverlay` is set to true, the tour will be shown above all other [Overlay]s.
  ///
  /// This method can be expensive as it walks the element tree.
  final bool useRootOverlay;

  /// Creates a new IntroduceConfig based on these values.
  IntroduceConfig copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
    bool? useRootOverlay,
  }) {
    return IntroduceConfig._(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      quadrantAlignment: quadrantAlignment ?? this.quadrantAlignment,
      useRootOverlay: useRootOverlay ?? this.useRootOverlay,
    );
  }
}

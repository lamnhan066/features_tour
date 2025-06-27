import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class IntroduceConfig {
  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

  /// Color of the background for the `introduce` widget.
  final Color? backgroundColor;

  /// Padding around the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// Quadrant rectangle for positioning the `introduce` widget.
  final QuadrantAlignment? quadrantAlignment;

  /// Alignment of the `introduce` widget within the specified `quadrantAlignment`.
  /// This value automatically aligns the widget depending on the chosen
  /// `quadrantAlignment`. It aims to keep the widget as close as possible to
  /// the other elements.
  final Alignment? alignment;

  /// If `useRootOverlay` is set to true, the tour will show above all other [Overlay]s.
  ///
  /// This method can be expensive (it walks the element tree).
  final bool useRootOverlay;

  const IntroduceConfig._({
    this.backgroundColor,
    this.padding = const EdgeInsets.all(20.0),
    this.quadrantAlignment,
    this.alignment,
    this.useRootOverlay = false,
  });

  /// Create a new IntroduceConfig base on [global] values.
  factory IntroduceConfig({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
    @Deprecated(
        'Dark/light themes are automatically applied. So this value is no longer needed.')
    bool? applyDarkTheme,
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

  /// Create a new IntroduceConfig base on this values.
  IntroduceConfig copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
    @Deprecated(
        'Dark/light themes are automatically applied. So this value is no longer needed.')
    bool? applyDarkTheme,
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

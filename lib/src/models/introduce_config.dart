import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class IntroduceConfig {
  /// Global configuration
  static IntroduceConfig global = const IntroduceConfig._();

  /// Color of the background
  final Color backgroundColor;

  /// Padding of the `introduce` widget
  final EdgeInsetsGeometry padding;

  /// Alignmnent of the `introduce` widget in side `quarantAlignment`.
  ///
  /// This value automatically aligns depending on the `quarantAlignment`.
  /// Make it as close as possible to other.
  final Alignment? alignment;

  /// Quadrant rectangle for `introduce` widget.
  final QuadrantAlignment quadrantAlignment;

  const IntroduceConfig._({
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.all(20.0),
    this.alignment,
    this.quadrantAlignment = QuadrantAlignment.top,
  });

  /// Create a new IntroduceConfig base on [global] values
  factory IntroduceConfig.copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
  }) {
    return IntroduceConfig._(
      backgroundColor: backgroundColor ?? global.backgroundColor,
      padding: padding ?? global.padding,
      alignment: alignment ?? global.alignment,
      quadrantAlignment: quadrantAlignment ?? global.quadrantAlignment,
    );
  }

  /// Create a new IntroduceConfig base on this values
  IntroduceConfig copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
  }) {
    return IntroduceConfig._(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      quadrantAlignment: quadrantAlignment ?? this.quadrantAlignment,
    );
  }
}

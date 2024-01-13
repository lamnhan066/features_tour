import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class IntroduceConfig {
  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

  /// Color of the background.
  final Color backgroundColor;

  /// Padding of the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// Quadrant rectangle for `introduce` widget.
  final QuadrantAlignment? quadrantAlignment;

  /// Alignmnent of the `introduce` widget in side `quarantAlignment`.
  ///
  /// This value automatically aligns depending on the `quarantAlignment`.
  /// Make it as close as possible to other.
  final Alignment? alignment;

  const IntroduceConfig._({
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.all(20.0),
    this.quadrantAlignment,
    this.alignment,
  });

  /// Create a new IntroduceConfig base on [global] values.
  ///
  /// [backgroundColor] is the color of the background. Default is `Colors.black87`.
  ///
  /// [padding] is the padding of the `introduce` widget. Default is `EdgeInsets.all(20.0)`.
  ///
  /// [quadrantAlignment] is the quadrant rectangle for `introduce` widget.
  /// Default is `QuadrantAlignment.top`. Means the `introduce` widget will
  /// show at the top of the main `child`.
  ///
  /// [alignment] is the alignmnent of the `introduce` widget in side `quarantAlignment`.
  /// This value automatically aligns depending on the `quadrantAlignment`.
  /// Make it as close as possible to other.
  factory IntroduceConfig.copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
  }) {
    return global.copyWith(
      backgroundColor: backgroundColor,
      padding: padding,
      alignment: alignment,
      quadrantAlignment: quadrantAlignment,
    );
  }

  /// Create a new IntroduceConfig base on this values.
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

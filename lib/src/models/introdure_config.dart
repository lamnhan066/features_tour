import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class IntrodureConfig {
  /// Global configuration
  static IntrodureConfig global = const IntrodureConfig();

  /// Color of the background
  final Color backgroundColor;

  /// Padding of the `introdure` widget
  final EdgeInsetsGeometry padding;

  /// Alignmnent of the `introdure` widget in side `quarantAlignment`.
  ///
  /// This value automatically aligns depending on the `quarantAlignment`.
  /// Make it as close as possible to other.
  final Alignment? alignment;

  /// Quadrant rectangle for `introdure` widget.
  final QuadrantAlignment quadrantAlignment;

  /// Animation duration of the `child` widget when show up on the instruction
  final Duration animationDuration;

  const IntrodureConfig({
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.all(20.0),
    this.alignment,
    this.quadrantAlignment = QuadrantAlignment.top,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  IntrodureConfig copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
  }) {
    return IntrodureConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      quadrantAlignment: quadrantAlignment ?? this.quadrantAlignment,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

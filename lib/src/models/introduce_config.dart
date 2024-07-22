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

  /// Auto apply the dark theme to the `introduce` Widget.
  ///
  /// The `introduce` background color is usually a dark color ([Colors.black87]
  /// by default), so the foreground widget is usually a light color (like white
  /// text). So this value will force the foreground widget use the dark theme
  /// to make it visible on the dark background.
  final bool applyDarkTheme;

  const IntroduceConfig._({
    this.backgroundColor = Colors.black87,
    this.padding = const EdgeInsets.all(20.0),
    this.quadrantAlignment,
    this.alignment,
    this.applyDarkTheme = true,
  });

  /// Create a new IntroduceConfig base on [global] values.
  factory IntroduceConfig({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
    bool? applyDarkTheme,
  }) {
    return global.copyWith(
      backgroundColor: backgroundColor,
      padding: padding,
      alignment: alignment,
      quadrantAlignment: quadrantAlignment,
      applyDarkTheme: applyDarkTheme,
    );
  }

  /// Create a new IntroduceConfig base on [global] values.
  @Deprecated('Use `IntroduceConfig` instead.')
  factory IntroduceConfig.copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
    bool? applyDarkTheme,
  }) = IntroduceConfig;

  /// Create a new IntroduceConfig base on this values.
  IntroduceConfig copyWith({
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
    bool? applyDarkTheme,
  }) {
    return IntroduceConfig._(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      quadrantAlignment: quadrantAlignment ?? this.quadrantAlignment,
      applyDarkTheme: applyDarkTheme ?? this.applyDarkTheme,
    );
  }
}

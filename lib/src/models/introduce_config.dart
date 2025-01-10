import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

class IntroduceConfig {
  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

  /// Color of the background for the `introduce` widget.
  final Color backgroundColor;

  /// Padding around the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// Quadrant rectangle for positioning the `introduce` widget.
  final QuadrantAlignment? quadrantAlignment;

  /// Alignment of the `introduce` widget within the specified `quadrantAlignment`.
  /// This value automatically aligns the widget depending on the chosen
  /// `quadrantAlignment`. It aims to keep the widget as close as possible to
  /// the other elements.
  final Alignment? alignment;

  /// Automatically applies the dark theme to the `introduce` widget.
  ///
  /// The `introduce` widget typically uses a dark background color (default is
  /// [Colors.black87]), so the foreground elements (like text) are usually
  /// light-colored. When this value is set to `true`, it forces the foreground
  /// widget to use the dark theme, ensuring visibility on the dark background.
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

import 'package:flutter/material.dart';

class ChildConfig {
  /// Global configuration
  static ChildConfig global = const ChildConfig();

  /// If this `child` is null, the original `child` will be used.
  final Widget? child;

  /// Background color of the `child` widget.
  ///
  /// This color is useful for TextField, Text, TextButton,.. which does not
  /// have a background color.
  final Color backgroundColor;

  /// Shape of border of the background. Default is Rectangle.
  ///
  /// Something like: `RoundedRectangleBorder()`, `CircleBorder()`
  final ShapeBorder? shapeBorder;

  /// Border radius of the background of the child. Default is `BorderRadius.all(12)`.
  final BorderRadiusGeometry borderRadius;

  /// Zoom scale of the `child` widget when show up on the instruction
  final double zoomScale;

  /// Animation of the `child` widget when show up on the instruction
  final Curve curve;

  const ChildConfig({
    this.child,
    this.backgroundColor = Colors.transparent,
    this.shapeBorder,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.zoomScale = 1.5,
    this.curve = Curves.decelerate,
  });

  ChildConfig copyWith({
    Widget? child,
    Color? backgroundColor,
    ShapeBorder? shapeBorder,
    BorderRadiusGeometry? borderRadius,
    double? zoomScale,
    Curve? curve,
  }) {
    return ChildConfig(
      child: child ?? this.child,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      shapeBorder: shapeBorder ?? this.shapeBorder,
      borderRadius: borderRadius ?? this.borderRadius,
      zoomScale: zoomScale ?? this.zoomScale,
      curve: curve ?? this.curve,
    );
  }
}

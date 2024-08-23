import 'package:flutter/material.dart';

class ChildConfig {
  /// Global configuration.
  static ChildConfig global = const ChildConfig._();

  /// If this `child` is null, the original `child` will be used.
  ///
  /// The original child is alse passed through the function.
  final Widget Function(Widget child)? child;

  /// Also scale child widget along with the border.
  final bool isAnimateChild;

  /// How bigger the border rectangle is when compared to the child widget.
  final double borderSizeInflate;

  /// Background color of the `child` widget.
  ///
  /// This color is useful for TextField, Text, TextButton,.. which does not
  /// have a background color.
  final Color? backgroundColor;

  /// Tap anywhere on the background to dismiss the current introduce. Default is
  /// set to `false`.
  final bool barrierDismissible;

  /// Shape of border of the background. Default is `RoundedRectangleBorder()`.
  ///
  /// Something like: `RoundedRectangleBorder()`, `CircleBorder()`.
  ///
  // ignore: deprecated_member_use_from_same_package
  /// If this value is specified, the [borderRadius] will be ignored.
  final ShapeBorder? shapeBorder;

  /// Border radius of the background of the child. Default is `BorderRadius.all(12)`.
  ///
  /// This value will be ignored if the [shapeBorder] is specified.
  @Deprecated('Use `shapeBorder` instead')
  final BorderRadiusGeometry borderRadius;

  /// Zoom scale of the `child` widget when show up on the instruction.
  final double zoomScale;

  /// Animation of the `child` widget when show up on the instruction.
  final Curve curve;

  /// Animation duration of the `child` widget when show up on the instruction.
  final Duration animationDuration;

  /// Default value of the `child` widget.
  const ChildConfig._({
    this.child,
    this.isAnimateChild = true,
    this.borderSizeInflate = 3,
    this.backgroundColor,
    this.barrierDismissible = false,
    this.shapeBorder,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.zoomScale = 1.2,
    this.curve = Curves.decelerate,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  /// Apply new settings to the `child` widget base on [global] settings.
  ///
  /// If this [child] is null, the original [child] will be used.
  ///
  /// [isAnimateChild] will let the child be animated along with the border. Default is `true`.
  ///
  /// [borderSizeInflate] is how big the border rectangle is when compared to the child widget.
  /// Default is `3`.
  ///
  /// [backgroundColor] is the background color of the `child` widget. Default is `Colors.transparent`.
  /// This color is useful for TextField, Text, TextButton,.. which does not
  /// have a background color.
  ///
  /// [barrierDismissible] Tap anywhere on the background to dismiss the current introduce. Default is
  /// set to `false`.
  ///
  /// [shapeBorder] is the shape of border of the background. Default is Rectangle.
  /// Something like: `RoundedRectangleBorder()`, `CircleBorder()`
  ///
  /// [borderRadius] is radius of the background of the child.
  /// Default is `BorderRadius.all(Radius.circular(12))`.
  ///
  /// [zoomScale] is the zoom scale of the `child` widget when show up on the instruction.
  /// Default is `1.2`.
  ///
  /// [curve] is the animation of the `child` widget when show up on the instruction.
  /// Default is `Curves.decelerate`.
  ///
  /// [animationDuration] is the animation duration of the `child` widget when show up on the instruction.
  /// Default is `Duration(milliseconds: 600)`.
  factory ChildConfig({
    Widget Function(Widget child)? child,
    bool? isAnimateChild,
    double? borderSizeInflate,
    Color? backgroundColor,
    bool? barrierDismissible,
    ShapeBorder? shapeBorder,
    BorderRadiusGeometry? borderRadius,
    @Deprecated('Use `shapeBorder` instead') Color? borderColor,
    double? zoomScale,
    Curve? curve,
    Duration? animationDuration,
  }) {
    return global.copyWith(
      child: child,
      isAnimateChild: isAnimateChild,
      borderSizeInflate: borderSizeInflate,
      backgroundColor: backgroundColor,
      barrierDismissible: barrierDismissible,
      shapeBorder: shapeBorder,
      // ignore: deprecated_member_use_from_same_package
      borderRadius: borderRadius,
      zoomScale: zoomScale,
      curve: curve,
      animationDuration: animationDuration,
    );
  }

  /// Apply new settings to the `child` widget base on [global] settings.
  ///
  /// If this [child] is null, the original [child] will be used.
  ///
  /// [isAnimateChild] will let the child be animated along with the border. Default is `true`.
  ///
  /// [borderSizeInflate] is how big the border rectangle is when compared to the child widget.
  /// Default is `3`.
  ///
  /// [backgroundColor] is the background color of the `child` widget. Default is `Colors.transparent`.
  /// This color is useful for TextField, Text, TextButton,.. which does not
  /// have a background color.
  ///
  /// [barrierDismissible] Tap anywhere on the background to dismiss the current introduce. Default is
  /// set to `false`.
  ///
  /// [shapeBorder] is the shape of border of the background. Default is Rectangle.
  /// Something like: `RoundedRectangleBorder()`, `CircleBorder()`
  ///
  /// [borderRadius] is radius of the background of the child.
  /// Default is `BorderRadius.all(Radius.circular(12))`.
  ///
  /// [zoomScale] is the zoom scale of the `child` widget when show up on the instruction.
  /// Default is `1.2`.
  ///
  /// [curve] is the animation of the `child` widget when show up on the instruction.
  /// Default is `Curves.decelerate`.
  ///
  /// [animationDuration] is the animation duration of the `child` widget when show up on the instruction.
  /// Default is `Duration(milliseconds: 600)`.
  @Deprecated('Use `ChildConfig` instead.')
  factory ChildConfig.copyWith({
    Widget Function(Widget child)? child,
    bool? isAnimateChild,
    double? borderSizeInflate,
    Color? backgroundColor,
    bool? barrierDismissible,
    ShapeBorder? shapeBorder,
    @Deprecated('Use `shapeBorder` instead') BorderRadiusGeometry? borderRadius,
    double? zoomScale,
    Curve? curve,
    Duration? animationDuration,
  }) = ChildConfig;

  /// Apply new settings to the current settings.
  ChildConfig copyWith({
    Widget Function(Widget child)? child,
    bool? isAnimateChild,
    double? borderSizeInflate,
    Color? backgroundColor,
    bool? barrierDismissible,
    ShapeBorder? shapeBorder,
    @Deprecated('Use `shapeBorder` instead') BorderRadiusGeometry? borderRadius,
    double? zoomScale,
    Curve? curve,
    Duration? animationDuration,
  }) {
    return ChildConfig._(
      child: child ?? this.child,
      isAnimateChild: isAnimateChild ?? this.isAnimateChild,
      borderSizeInflate: borderSizeInflate ?? this.borderSizeInflate,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      shapeBorder: shapeBorder ?? this.shapeBorder,
      // ignore: deprecated_member_use_from_same_package
      borderRadius: borderRadius ?? this.borderRadius,
      zoomScale: zoomScale ?? this.zoomScale,
      curve: curve ?? this.curve,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

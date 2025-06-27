import 'package:flutter/material.dart';

class ChildConfig {
  /// Global configuration.
  static ChildConfig global = const ChildConfig._();

  /// If this `child` is `null`, the original `child` will be used. The original
  /// child is also passed through the function.
  final Widget Function(Widget child)? child;

  /// Determines whether the child widget should scale along with the border.
  /// If set to `true`, the child will scale when the border scales.
  final bool isAnimateChild;

  /// Specifies how much larger the border rectangle is compared to the child
  /// widget. This value controls the border's size relative to the child.
  final double borderSizeInflate;

  /// Sets the background color of the `child` widget. This is particularly useful
  /// for widgets like [TextField], [Text], and [TextButton], which don't have
  /// a background color by default.
  final Color? backgroundColor;

  /// If set to `true`, tapping anywhere on the background will dismiss the
  /// current introduction. Defaults to `false`.
  final bool barrierDismissible;

  /// Specifies the shape of the background's border. By default, it is a
  /// `RoundedRectangleBorder()`. You can set this to shapes like
  // ignore: deprecated_member_use_from_same_package
  /// `RoundedRectangleBorder()` or `CircleBorder()`. If specified, the [borderRadius]
  /// will be ignored.
  final ShapeBorder? shapeBorder;

  /// Defines the border radius of the background around the child widget. The default
  /// is `BorderRadius.all(12)`. This value will be ignored if [shapeBorder] is specified.
  @Deprecated('Use `shapeBorder` instead')
  final BorderRadiusGeometry borderRadius;

  /// Specifies the zoom scale of the `child` widget when it is shown during the
  /// introduction. A larger value will make the child appear zoomed in.
  final double zoomScale;

  /// Defines the animation curve used for the `child` widget when it appears during
  /// the introduction. This curve controls the easing of the animation.
  final Curve curve;

  /// Specifies the duration of the animation for the `child` widget when it appears
  /// during the introduction. This controls how long the animation lasts.
  final Duration animationDuration;

  /// If set to `false`, no animation will be applied to the current child widget
  /// during the introduction. When set to `true`, the [zoomScale], [curve], and
  /// [animationDuration] are used. Defaults to `true`.
  final bool enableAnimation;

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
    this.enableAnimation = true,
  });

  /// Apply new settings to the `child` widget base on [global] settings.
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
    bool? enableAnimation,
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
      enableAnimation: enableAnimation,
    );
  }

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
    bool? enableAnimation,
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
      enableAnimation: enableAnimation ?? this.enableAnimation,
    );
  }
}

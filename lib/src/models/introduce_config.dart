import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

/// A builder function to wrap the `introduce` widget.
typedef IntroduceBuilder = Widget Function(
  BuildContext context,
  Rect childRect,
  Widget introduce,
);

/// A builder function to determine the color of the modal barrier that darkens
/// everything behind the tour.
typedef BarrierColorBuilder = Color Function(BuildContext context);

/// Configuration for the `introduce` widget in the Features Tour.
class IntroduceConfig {
  /// Creates a new IntroduceConfig based on [global] values.
  ///
  /// Using [builder] to customize the appearance of the `introduce` widget.
  ///
  /// Using [barrierColorBuilder] to customize the color of the modal barrier.
  ///
  /// Using [padding] to set the padding around the `introduce` widget. This
  /// value is used to create space between the `introduce` widget and the
  /// `child` widget. Default is set to `EdgeInsets.all(20)`.
  ///
  /// You can also use [quadrantAlignment] and [alignment] to position
  /// the `introduce` widget relative to the `child` widget. These values
  /// are mostly automatically handled by the package.
  ///
  /// Using [useRootOverlay] to determine if the tour should be shown above
  /// all other [Overlay]s. Default is set to false.
  ///
  /// See also:
  ///   * [RoundedRectIntroduceConfig] for a configuration with rounded rectangle
  ///     decoration and better visible barrier color.
  factory IntroduceConfig({
    IntroduceBuilder? builder,
    @Deprecated('Use barrierColorBuilder instead') Color? backgroundColor,
    BarrierColorBuilder? barrierColorBuilder,
    EdgeInsetsGeometry? padding,
    QuadrantAlignment? quadrantAlignment,
    Alignment? alignment,
    bool? useRootOverlay,
  }) {
    return global.copyWith(
      builder: builder,
      barrierColorBuilder: backgroundColor != null
          ? (builder) => backgroundColor
          : barrierColorBuilder,
      padding: padding,
      alignment: alignment,
      quadrantAlignment: quadrantAlignment,
      useRootOverlay: useRootOverlay,
    );
  }

  const IntroduceConfig._({
    required this.builder,
    required this.barrierColorBuilder,
    this.padding = const EdgeInsets.all(20),
    this.quadrantAlignment,
    this.alignment,
    this.useRootOverlay = false,
  });

  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._(
    builder: _introduceDefaultBuilder,
    barrierColorBuilder: _barrierColorDefaultBuilder,
  );

  /// A builder function to wrap the `introduce` widget.
  final IntroduceBuilder builder;

  /// The color of the modal barrier that darkens everything behind the tour.
  final Color Function(BuildContext context) barrierColorBuilder;

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
    IntroduceBuilder? builder,
    @Deprecated('Use barrierColorBuilder instead') Color? backgroundColor,
    BarrierColorBuilder? barrierColorBuilder,
    EdgeInsetsGeometry? padding,
    Alignment? alignment,
    QuadrantAlignment? quadrantAlignment,
    Duration? animationDuration,
    bool? useRootOverlay,
  }) {
    return IntroduceConfig._(
      builder: builder ?? this.builder,
      barrierColorBuilder: backgroundColor != null
          ? (builder) => backgroundColor
          : (barrierColorBuilder ?? this.barrierColorBuilder),
      padding: padding ?? this.padding,
      alignment: alignment ?? this.alignment,
      quadrantAlignment: quadrantAlignment ?? this.quadrantAlignment,
      useRootOverlay: useRootOverlay ?? this.useRootOverlay,
    );
  }

  static Widget _introduceDefaultBuilder(
    BuildContext context,
    Rect childRect,
    Widget introduce,
  ) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: Theme.brightnessOf(context) == Brightness.dark
            ? Colors.black
            : Colors.white,
      ),
      child: introduce,
    );
  }

  static Color _barrierColorDefaultBuilder(BuildContext context) {
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }
}

/// An IntroduceConfig with rounded rectangle decoration and better visible barrier color.
class RoundedRectIntroduceConfig extends IntroduceConfig {
  /// Creates a new RoundedRectIntroduceConfig with rounded rectangle decoration.
  RoundedRectIntroduceConfig({double borderRadius = 4})
      : super._(
          builder: (context, childRect, introduce) {
            return _introduceRoundedRectBuilder(
              context,
              childRect,
              introduce,
              borderRadius,
            );
          },
          barrierColorBuilder: _barrierColorBetterVisibleBuilder,
        );

  /// A builder function that wraps the `introduce` widget with a rounded rectangle.`
  static Widget _introduceRoundedRectBuilder(
    BuildContext context,
    Rect childRect,
    Widget introduce,
    double borderRadius,
  ) {
    final brightness = Theme.brightnessOf(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withValues(alpha: .85)
            : Colors.white.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: Theme.brightnessOf(context) == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        child: introduce,
      ),
    );
  }

  /// A better visible barrier color builder that adjusts the alpha based on
  /// the current theme brightness.

  static Color _barrierColorBetterVisibleBuilder(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColorScheme.of(context).onSurface.withValues(alpha: 0.18);
    }
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }
}

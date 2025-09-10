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
  factory IntroduceConfig({
    IntroduceBuilder builder = _defaultBuilder,
    @Deprecated('Use barrierColorBuilder instead') Color? backgroundColor,
    BarrierColorBuilder barrierColorBuilder = _defaultBarrierColorBuilder,
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
    this.builder = _defaultBuilder,
    this.barrierColorBuilder = _defaultBarrierColorBuilder,
    this.padding = const EdgeInsets.all(20),
    this.quadrantAlignment,
    this.alignment,
    this.useRootOverlay = false,
  });

  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

  /// The default builder function to wrap the `introduce` widget.
  static Widget _defaultBuilder(
    BuildContext context,
    Rect childRect,
    Widget introduce,
  ) {
    final brightness = Theme.brightnessOf(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? Colors.black.withValues(alpha: .85)
            : Colors.white.withValues(alpha: .85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: introduce,
    );
  }

  static Color _defaultBarrierColorBuilder(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColorScheme.of(context).onSurface.withValues(alpha: 0.18);
    }
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }

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
}

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
  /// Default is set to [IntroduceDecorations.introduceDefaultBuilder].
  ///
  /// Using [barrierColorBuilder] to customize the color of the modal barrier.
  /// Default is set to [IntroduceDecorations.barrierColorDefaultBuilder].
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
  ///   * [IntroduceBuilder]: A function that builds the `introduce` widget.
  ///     * [IntroduceDecorations.introduceDefaultBuilder]
  ///     * [IntroduceDecorations.introduceRoundedRectBuilder]
  ///   * [BarrierColorBuilder]: A function that builds the color of the modal barrier.
  ///     * [IntroduceDecorations.barrierColorDefaultBuilder]
  ///     * [IntroduceDecorations.barrierColorBetterVisibleBuilder]
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
    this.builder = IntroduceDecorations.introduceDefaultBuilder,
    this.barrierColorBuilder = IntroduceDecorations.barrierColorDefaultBuilder,
    this.padding = const EdgeInsets.all(20),
    this.quadrantAlignment,
    this.alignment,
    this.useRootOverlay = false,
  });

  /// Global configuration.
  static IntroduceConfig global = const IntroduceConfig._();

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

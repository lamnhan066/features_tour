import 'package:flutter/material.dart';

/// A collection of predefined decoration builders for the `introduce` widget.
abstract class IntroduceDecorations {
  /// The default builder function to wrap the `introduce` widget.
  static Widget introduceDefaultBuilder(
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

  /// A builder function that wraps the `introduce` widget with a rounded rectangle.`
  static Widget introduceRoundedRectBuilder(
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

  /// A default barrier color builder that darkens everything behind the tour.
  static Color barrierColorDefaultBuilder(BuildContext context) {
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }

  /// A better visible barrier color builder that adjusts the alpha based on
  /// the current theme brightness.
  ///
  /// This builder is harder to see in dark mode if using with the
  /// [introduceDefaultBuilder], it should be used with the [introduceRoundedRectBuilder].
  static Color barrierColorBetterVisibleBuilder(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return ColorScheme.of(context).onSurface.withValues(alpha: 0.18);
    }
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }
}

import 'package:flutter/material.dart';

/// The base configuration for buttons used in the Features Tour.
abstract class BaseButtonConfig {
  /// Creates a [BaseButtonConfig] instance.
  const BaseButtonConfig({
    @Deprecated('Use builder instead') this.child,
    this.builder,
    this.text = '',
    this.alignment = Alignment.bottomRight,
    this.color,
    this.enabled = true,
    this.textStyle,
    this.buttonStyle,
  }) : assert(
          child == null || builder == null,
          'Cannot provide both child and builder. Use builder instead of child.',
        );

  /// A custom widget for the button.
  /// When this widget is set, you must pass the `onPressed` callback to the button's `onPressed` or `onTap` property.
  ///
  /// Example:
  /// ```dart
  /// child: (onPressed) => ElevatedButton(
  ///   onPressed: onPressed,
  ///   child: Text('This is a button'),
  /// ),
  /// ```
  @Deprecated('Use builder instead')
  final Widget Function(VoidCallback onPressed)? child;

  /// A builder function that provides a context and an `onPressed` callback
  /// to create a custom button widget.
  final Widget Function(BuildContext context, VoidCallback onPressed)? builder;

  /// The base text displayed on the button.
  final String text;

  /// The alignment of the button within its parent widget.
  final Alignment alignment;

  /// The color of the button text. For more customization, use [textStyle].
  final Color? color;

  /// Determines whether the button is enabled or disabled.
  final bool enabled;

  /// The text style of the button text. This overrides the default styling.
  final TextStyle? textStyle;

  /// The [ButtonStyle] applied to the button.
  ///
  /// Example:
  /// ```dart
  /// buttonStyle: TextButton.styleFrom(
  ///   shape: RoundedRectangleBorder(
  ///     side: BorderSide(color: Colors.red),
  ///     borderRadius: BorderRadius.circular(10),
  ///   ),
  /// ),
  /// ```
  final ButtonStyle? buttonStyle;

  /// Creates a new BaseConfig based on these values.
  BaseButtonConfig copyWith({
    @Deprecated('Use builder instead')
    Widget Function(VoidCallback onPressed)? child,
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  });
}

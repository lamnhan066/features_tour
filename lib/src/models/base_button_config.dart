import 'package:flutter/material.dart';

abstract class BaseButtonConfig {
  /// Custom widget for the button.
  /// When this widget is set, you must pass the `onPressed` callback to the button's `onPressed` or `onTap` property.
  ///
  /// Example:
  /// ```dart
  /// child: (onPressed) => ElevatedButton(
  ///   onPressed: onPressed,
  ///   child: Text('This is a button'),
  /// ),
  /// ```
  final Widget Function(VoidCallback onPressed)? child;

  /// The base text displayed on the button.
  final String text;

  /// The alignment of the button within its parent widget.
  final Alignment alignment;

  /// The color of the button text. For more customization, use [textStyle].
  final Color? color;

  /// Determines whether the button is enabled or disabled.
  final bool enabled;

  /// The text style of the button text. Overrides the default styling.
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

  const BaseButtonConfig({
    this.child,
    this.text = '',
    this.alignment = Alignment.bottomRight,
    this.color,
    this.enabled = true,
    this.textStyle,
    this.buttonStyle,
  });

  /// Create a new BaseConfig base on this values.
  BaseButtonConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  });
}

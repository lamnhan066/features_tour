import 'package:flutter/material.dart';

abstract class BaseConfig {
  /// Modified widget for the next button. When this Widget is set, you have to
  /// pass the `onPressed` method to the `onPressed` or `onTap`.
  ///
  /// Ex:
  /// child: (onPressed) => ElevatedButton(
  ///   onPressed: onPressed,
  ///   child: Text('This is a button'),
  /// ),
  final Widget Function(VoidCallback onPressed)? child;

  /// Base button text.
  final String text;

  /// Position of the button.
  final Alignment alignment;

  /// Color of the Base text. You can use [textStyle] for more control.
  final Color? color;

  /// Enable or disable the button.
  final bool enabled;

  /// Set the style for the text.
  final TextStyle? textStyle;

  /// The [ButtonStyle] of the button.
  /// Default:
  /// ``` dart
  ///    style: TextButton.styleFrom(
  ///      shape: RoundedRectangleBorder(
  ///        side: const BorderSide(
  ///          color: Colors.red,
  ///        ),
  ///        borderRadius: BorderRadius.circular(10),
  ///      ),
  ///    ),
  ///  ),
  /// ```
  final ButtonStyle? buttonStyle;

  const BaseConfig({
    this.child,
    this.text = '',
    this.alignment = Alignment.bottomRight,
    this.color,
    this.enabled = true,
    this.textStyle,
    this.buttonStyle,
  });

  /// Create a new BaseConfig base on this values.
  BaseConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  });
}

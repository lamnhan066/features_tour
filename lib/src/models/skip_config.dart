import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

class SkipConfig extends BaseButtonConfig {
  /// Global configuration.
  static SkipConfig global = const SkipConfig._();

  /// Call the `onPressed` action when the skip button is pressed. Default is `false`.
  final bool isCallOnPressed;

  const SkipConfig._({
    super.child,
    super.text = 'SKIP',
    super.alignment = Alignment.bottomLeft,
    super.color,
    super.enabled = true,
    this.isCallOnPressed = false,
    super.textStyle,
    super.buttonStyle,
  });

  /// Creates a new `SkipConfig` based on the provided [global] values.
  ///
  /// [child] is a custom widget for the skip button. When this is set,
  /// you must pass the `onPressed` method.
  /// Example:
  /// ```dart
  /// child: (onPressed) => FilledButton(
  ///   onPressed: onPressed,
  ///   child: const Text('SKIP'),
  /// ),
  /// ```
  ///
  /// [text] defines the label for the skip button. Defaults to 'SKIP'.
  ///
  /// [alignment] specifies the position of the skip text. Defaults to `Alignment.bottomLeft`.
  ///
  /// [color] determines the color of the skip text. Defaults to `null`.
  ///
  /// [enabled] indicates whether the skip button is enabled. Defaults to `true`.
  ///
  /// [isCallOnPressed] controls whether the tour calls `onPressed` when the skip button is clicked.
  /// Defaults to `false`, meaning it does not call `onPressed` by default.
  ///
  /// [textStyle] defines the [TextStyle] of the skip button text.
  ///
  /// [buttonStyle] defines the [ButtonStyle] of the button.
  /// Example:
  /// ```dart
  ///    buttonStyle: ElevatedButton.styleFrom(
  ///      shape: RoundedRectangleBorder(
  ///        side: const BorderSide(
  ///          color: Colors.red,
  ///        ),
  ///        borderRadius: BorderRadius.circular(10),
  ///      ),
  ///    ),
  ///  ),
  /// ```

  factory SkipConfig({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      child: child,
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      isCallOnPressed: isCallOnPressed,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  /// Creates a new `SkipConfig` based on the provided [global] values.
  ///
  /// [text] defines the label for the skip button. Defaults to 'SKIP'.
  ///
  /// [alignment] specifies the position of the skip text. Defaults to `Alignment.bottomLeft`.
  ///
  /// [color] determines the color of the skip text. Defaults to `null`.
  ///
  /// [enabled] indicates whether the skip button is enabled. Defaults to `true`.
  ///
  /// [isCallOnPressed] controls whether the tour calls `onPressed` when the skip button is clicked.
  /// Defaults to `false`, meaning it does not call `onPressed` by default.
  ///
  /// [textStyle] defines the [TextStyle] of the skip button text.
  ///
  /// [buttonStyle] defines the [ButtonStyle] of the button.
  /// Example:
  /// ```dart
  ///    buttonStyle: ElevatedButton.styleFrom(
  ///      shape: RoundedRectangleBorder(
  ///        side: const BorderSide(
  ///          color: Colors.red,
  ///        ),
  ///        borderRadius: BorderRadius.circular(10),
  ///      ),
  ///    ),
  ///  ),
  /// ```

  @Deprecated('Use `SkipConfig` instead.')
  factory SkipConfig.copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) = SkipConfig;

  /// Create a new SkipConfig base on this values.
  @override
  SkipConfig copyWith({
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    bool? isCallOnPressed,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return SkipConfig._(
      child: child,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      isCallOnPressed: isCallOnPressed ?? this.isCallOnPressed,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}

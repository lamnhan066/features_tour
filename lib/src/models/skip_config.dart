import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

/// Configuration for the "Skip" button in the Features Tour.
class SkipConfig extends BaseButtonConfig {
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
  /// [text] defines the label for the skip button. The default is 'SKIP'.
  ///
  /// [alignment] specifies the position of the skip text. The default is `Alignment.bottomLeft`.
  ///
  /// [color] determines the color of the skip text. The default is `null`.
  ///
  /// [enabled] indicates whether the skip button is enabled. The default is `true`.
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
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    @Deprecated('Use builder instead')
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      builder: builder,
      // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
      // ignore: deprecated_member_use_from_same_package
      child: child,
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  const SkipConfig._({
    @Deprecated('Use builder instead') super.child,
    super.builder,
    super.text = 'SKIP',
    super.alignment = Alignment.bottomLeft,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Global configuration.
  static SkipConfig global = const SkipConfig._();

  /// Creates a new SkipConfig based on these values.
  @override
  SkipConfig copyWith({
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    @Deprecated('Use builder instead')
    Widget Function(VoidCallback onPressed)? child,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return SkipConfig._(
      builder: builder ?? this.builder,
      // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
      // ignore: deprecated_member_use_from_same_package
      child: child,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}

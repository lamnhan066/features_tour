import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

/// Configuration for the "Next" button in the Features Tour.
class NextConfig extends BaseButtonConfig {
  /// Creates a new [NextConfig] based on the [global] values.
  ///
  /// [child] is a custom widget for the next button. When this is set,
  /// you must pass the `onPressed` method.
  /// Example:
  /// ```dart
  /// child: (onPressed) => FilledButton(
  ///   onPressed: onPressed,
  ///   child: const Text('NEXT'),
  /// ),
  /// ```
  ///
  /// [builder] is a builder function that provides a context and an `onPressed` callback
  /// to create a custom next button widget.
  ///
  /// [text] defines the text on the next button. The default is "NEXT".
  ///
  /// [alignment] specifies the alignment of the next button. The default is
  /// `Alignment.bottomRight`.
  ///
  /// [color] sets the color of the next button text. The default is `null`.
  ///
  /// [enabled] indicates whether the next button is enabled. The default is `true`.
  ///
  /// [textStyle] defines the [TextStyle] for the button text.
  ///
  /// [buttonStyle] specifies the [ButtonStyle] of the button.
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
  factory NextConfig({
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

  const NextConfig._({
    @Deprecated('Use builder instead') super.child,
    super.builder,
    super.text = 'NEXT',
    super.alignment = Alignment.bottomRight,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Global configuration.
  static NextConfig global = const NextConfig._();

  /// Creates a new NextConfig based on these values.
  @override
  NextConfig copyWith({
    @Deprecated('Use builder instead')
    Widget Function(VoidCallback onPressed)? child,
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return NextConfig._(
      builder: builder ?? this.builder,
      // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
      // ignore: deprecated_member_use_from_same_package
      child: child ?? this.child,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}

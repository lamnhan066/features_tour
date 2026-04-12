import 'package:features_tour/src/models/base_button_config.dart';
import 'package:flutter/material.dart';

/// Configuration for the "Previous" button in the Features Tour.
class PreviousConfig extends BaseButtonConfig {
  /// Creates a new [PreviousConfig] based on the [global] values.
  factory PreviousConfig({
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return global.copyWith(
      builder: builder,
      text: text,
      alignment: alignment,
      color: color,
      enabled: enabled,
      textStyle: textStyle,
      buttonStyle: buttonStyle,
    );
  }

  const PreviousConfig._({
    super.builder,
    super.text = 'PREVIOUS',
    super.alignment = Alignment.bottomLeft,
    super.color,
    super.enabled = true,
    super.textStyle,
    super.buttonStyle,
  });

  /// Global configuration.
  static PreviousConfig global = const PreviousConfig._();

  /// Creates a new PreviousConfig based on these values.
  @override
  PreviousConfig copyWith({
    Widget Function(BuildContext context, VoidCallback onPressed)? builder,
    String? text,
    Alignment? alignment,
    Color? color,
    bool? enabled,
    TextStyle? textStyle,
    ButtonStyle? buttonStyle,
  }) {
    return PreviousConfig._(
      builder: builder ?? this.builder,
      text: text ?? this.text,
      alignment: alignment ?? this.alignment,
      color: color ?? this.color,
      enabled: enabled ?? this.enabled,
      textStyle: textStyle ?? this.textStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
    );
  }
}

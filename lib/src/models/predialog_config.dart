import 'dart:async';

import 'package:flutter/material.dart';

class PredialogConfig {
  /// Global configuration.
  static PredialogConfig global = PredialogConfig._();

  /// This is the configuration for Predialog.
  PredialogConfig._({
    this.enabled = true,
    this.title = 'Introduction',
    this.content =
        'This page has some new features that you might want to discover.\n\n'
            'Would you like to take a tour?',
    this.applyToAllPagesText = 'Apply to all pages',
    this.acceptButtonText = const Text('Okay'),
    this.acceptButtonStyle,
    this.laterButtonText = const Text('Later'),
    this.laterButtonStyle,
    this.dismissButtonText = const Text(
      'Dismiss',
      style: TextStyle(color: Colors.grey),
    ),
    this.dismissButtonStyle,
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.modifiedDialogResult,
  });

  /// Controls whether the Predialog is enabled or disabled.
  final bool enabled;

  /// Specifies the background color of the dialog.
  final Color backgroundColor;

  /// Defines the color for all the text within the dialog.
  final Color textColor;

  /// The title displayed at the top of the dialog. Defaults to 'Introduction'.
  final String title;

  /// The content message shown in the dialog. Defaults to "This page has some
  /// new features that you might want to discover.\n\nWould you like to take a tour?".
  final String content;

  /// The text for the checkbox that applies the tour to all pages. Defaults to 'Apply to all pages'.
  final String applyToAllPagesText;

  /// The text displayed on the accept button.
  final Text acceptButtonText;

  /// Defines the style for the accept button, which is an [ElevatedButton].
  final ButtonStyle? acceptButtonStyle;

  /// The text displayed on the later button for postponing the action.
  final Text laterButtonText;

  /// Defines the style for the later button, which is a [TextButton].
  final ButtonStyle? laterButtonStyle;

  /// The text displayed on the dismiss button to close the dialog without taking any action.
  final Text dismissButtonText;

  /// Defines the style for the dismiss button, which is a [TextButton].
  final ButtonStyle? dismissButtonStyle;

  /// The radius of the dialog's corners, giving it rounded edges.
  final double borderRadius;

  /// A custom function that provides a result for the modified dialog.
  /// If set, it overrides the default dialog behavior and other settings are ignored.
  final FutureOr<bool> Function(BuildContext context)? modifiedDialogResult;

  /// Creates a new pre-dialog based on the [global] values.
  ///
  /// [enabled] controls whether the pre-dialog is enabled or disabled.
  /// Defaults to `true`.
  ///
  /// [title] sets the title of the dialog. Defaults to 'Introduction'.
  ///
  /// [content] specifies the content of the dialog. Defaults to the message:
  /// "This page has some new features that you might want to discover.\n\nWould
  /// you like to take a tour?".
  ///
  /// [applyToAllPagesText] defines the text for the "apply to all pages" checkbox.
  /// Defaults to 'Apply to all pages'.
  ///
  /// [acceptButtonText] sets the text for the accept action button.
  ///
  /// [acceptButtonStyle] specifies the style for the accept button using [ElevatedButton].
  ///
  /// [laterButtonText] sets the text for the "ask again later" button.
  ///
  /// [laterButtonStyle] specifies the style for the later button using [TextButton].
  ///
  /// [dismissButtonText] sets the text for the dismiss button, preventing the
  /// tour from being shown again.
  ///
  /// [dismissButtonStyle] specifies the style for the dismiss button using [TextButton].
  ///
  /// [borderRadius] controls the radius of the dialog's border. Defaults to 12.0.
  ///
  /// [backgroundColor] defines the background color of the dialog. Defaults to `Colors.white`.
  ///
  /// [textColor] specifies the color of the text in the dialog. Defaults to `Colors.black`.

  factory PredialogConfig({
    bool? enabled,
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? applyToAllPagesText,
    String? content,
    Text? acceptButtonText,
    ButtonStyle? acceptButtonStyle,
    Text? laterButtonText,
    ButtonStyle? laterButtonStyle,
    Text? dismissButtonText,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
  }) {
    return global.copyWith(
      enabled: enabled,
      modifiedDialogResult: modifiedDialogResult,
      backgroundColor: backgroundColor,
      textColor: textColor,
      title: title,
      applyToAllPagesText: applyToAllPagesText,
      content: content,
      acceptButtonText: acceptButtonText,
      acceptButtonStyle: acceptButtonStyle,
      laterButtonText: laterButtonText,
      laterButtonStyle: laterButtonStyle,
      dismissButtonText: dismissButtonText,
      dismissButtonStyle: dismissButtonStyle,
      borderRadius: borderRadius,
    );
  }

  /// Creates a new pre-dialog based on the [global] values.
  ///
  /// [enabled] controls whether the pre-dialog is enabled or disabled.
  /// Defaults to `true`.
  ///
  /// [title] sets the title of the dialog. Defaults to 'Introduction'.
  ///
  /// [content] specifies the content of the dialog. Defaults to the message:
  /// "This page has some new features that you might want to discover.\n\nWould
  /// you like to take a tour?".
  ///
  /// [applyToAllPagesText] defines the text for the "apply to all pages" checkbox.
  /// Defaults to 'Apply to all pages'.
  ///
  /// [acceptButtonText] sets the text for the accept action button.
  ///
  /// [acceptButtonStyle] specifies the style for the accept button using [ElevatedButton].
  ///
  /// [laterButtonText] sets the text for the "ask again later" button.
  ///
  /// [laterButtonStyle] specifies the style for the later button using [TextButton].
  ///
  /// [dismissButtonText] sets the text for the dismiss button, preventing the
  /// tour from being shown again.
  ///
  /// [dismissButtonStyle] specifies the style for the dismiss button using [TextButton].
  ///
  /// [borderRadius] controls the radius of the dialog's border. Defaults to 12.0.
  ///
  /// [backgroundColor] defines the background color of the dialog. Defaults to `Colors.white`.
  ///
  /// [textColor] specifies the color of the text in the dialog. Defaults to `Colors.black`.

  @Deprecated('Use `PredialogConfig` instead.')
  factory PredialogConfig.copyWith({
    bool? enabled,
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? applyToAllPagesText,
    String? content,
    Text? acceptButtonText,
    ButtonStyle? acceptButtonStyle,
    Text? laterButtonText,
    ButtonStyle? laterButtonStyle,
    Text? dismissButtonText,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
  }) =>
      PredialogConfig as PredialogConfig;

  /// Create a new Predialog base on this values.
  PredialogConfig copyWith({
    bool? enabled,
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? content,
    String? applyToAllPagesText,
    Text? acceptButtonText,
    ButtonStyle? acceptButtonStyle,
    Text? laterButtonText,
    ButtonStyle? laterButtonStyle,
    Text? dismissButtonText,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
  }) {
    return PredialogConfig._(
      enabled: enabled ?? this.enabled,
      modifiedDialogResult: modifiedDialogResult ?? this.modifiedDialogResult,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      title: title ?? this.title,
      content: content ?? this.content,
      applyToAllPagesText: applyToAllPagesText ?? this.applyToAllPagesText,
      acceptButtonText: acceptButtonText ?? this.acceptButtonText,
      acceptButtonStyle: acceptButtonStyle ?? this.acceptButtonStyle,
      laterButtonText: laterButtonText ?? this.laterButtonText,
      laterButtonStyle: laterButtonStyle ?? this.laterButtonStyle,
      dismissButtonText: dismissButtonText ?? this.dismissButtonText,
      dismissButtonStyle: dismissButtonStyle ?? this.dismissButtonStyle,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

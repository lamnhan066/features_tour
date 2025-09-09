import 'dart:async';

import 'package:flutter/material.dart';

class PredialogConfig {

  /// Creates a new `PredialogConfig` instance with optional overrides.
  factory PredialogConfig({
    bool? enabled,
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? applyToAllPagesText,
    Color? applyToAllPagesTextColor,
    String? content,
    Text? acceptButtonText,
    ButtonStyle? acceptButtonStyle,
    Text? laterButtonText,
    ButtonStyle? laterButtonStyle,
    Text? dismissButtonText,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
    VoidCallback? onAcceptButtonPressed,
    VoidCallback? onLaterButtonPressed,
    VoidCallback? onDismissButtonPressed,
  }) {
    return global.copyWith(
      enabled: enabled,
      modifiedDialogResult: modifiedDialogResult,
      backgroundColor: backgroundColor,
      textColor: textColor,
      title: title,
      applyToAllPagesText: applyToAllPagesText,
      applyToAllPagesTextColor: applyToAllPagesTextColor,
      content: content,
      acceptButtonText: acceptButtonText,
      acceptButtonStyle: acceptButtonStyle,
      laterButtonText: laterButtonText,
      laterButtonStyle: laterButtonStyle,
      dismissButtonText: dismissButtonText,
      dismissButtonStyle: dismissButtonStyle,
      borderRadius: borderRadius,
      onAcceptButtonPressed: onAcceptButtonPressed,
      onLaterButtonPressed: onLaterButtonPressed,
      onDismissButtonPressed: onDismissButtonPressed,
    );
  }

  /// Creates a new instance of `PredialogConfig` with customizable options.
  PredialogConfig._({
    this.enabled = true,
    this.title = 'Introduction',
    this.content =
        'This page has some new features that you might want to discover.\n\n'
            'Would you like to take a tour?',
    this.applyToAllPagesText = 'Apply to all pages',
    this.applyToAllPagesTextColor,
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
    this.backgroundColor,
    this.textColor,
    this.modifiedDialogResult,
    this.onAcceptButtonPressed,
    this.onLaterButtonPressed,
    this.onDismissButtonPressed,
  });
  /// Global configuration instance.
  /// This allows for a shared default configuration across the app.
  static PredialogConfig global = PredialogConfig._();

  /// Whether the pre-dialog should be displayed or not.
  final bool enabled;

  /// Background color of the dialog.
  final Color? backgroundColor;

  /// Text color for the dialog content.
  final Color? textColor;

  /// Title of the dialog.
  final String title;

  /// Message content of the dialog.
  final String content;

  /// Label for the 'Apply to all pages' checkbox.
  final String applyToAllPagesText;

  /// Color of the 'Apply to all pages' label text, also applied to the checkbox.
  ///
  /// Defaults to [textColor], otherwise falls back to the primary color.
  final Color? applyToAllPagesTextColor;

  /// Text for the accept button.
  final Text acceptButtonText;

  /// Styling for the accept button (typically an `ElevatedButton`).
  final ButtonStyle? acceptButtonStyle;

  /// Text for the later button, allowing the user to postpone action.
  final Text laterButtonText;

  /// Styling for the later button (typically a `TextButton`).
  final ButtonStyle? laterButtonStyle;

  /// Text for the dismiss button, allowing the user to close the dialog.
  final Text dismissButtonText;

  /// Styling for the dismiss button (typically a `TextButton`).
  final ButtonStyle? dismissButtonStyle;

  /// The radius of the dialog's corners, making it rounded.
  final double borderRadius;

  /// Custom function to override the default dialog behavior.
  final FutureOr<bool> Function(BuildContext context)? modifiedDialogResult;

  /// Callback triggered when the accept button is pressed.
  final VoidCallback? onAcceptButtonPressed;

  /// Callback triggered when the later button is pressed.
  final VoidCallback? onLaterButtonPressed;

  /// Callback triggered when the dismiss button is pressed.
  final VoidCallback? onDismissButtonPressed;

  /// Creates a new `PredialogConfig` instance based on existing values.
  PredialogConfig copyWith({
    bool? enabled,
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? content,
    String? applyToAllPagesText,
    Color? applyToAllPagesTextColor,
    Text? acceptButtonText,
    ButtonStyle? acceptButtonStyle,
    Text? laterButtonText,
    ButtonStyle? laterButtonStyle,
    Text? dismissButtonText,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
    VoidCallback? onAcceptButtonPressed,
    VoidCallback? onLaterButtonPressed,
    VoidCallback? onDismissButtonPressed,
  }) {
    return PredialogConfig._(
      enabled: enabled ?? this.enabled,
      modifiedDialogResult: modifiedDialogResult ?? this.modifiedDialogResult,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      title: title ?? this.title,
      content: content ?? this.content,
      applyToAllPagesText: applyToAllPagesText ?? this.applyToAllPagesText,
      applyToAllPagesTextColor:
          applyToAllPagesTextColor ?? this.applyToAllPagesTextColor,
      acceptButtonText: acceptButtonText ?? this.acceptButtonText,
      acceptButtonStyle: acceptButtonStyle ?? this.acceptButtonStyle,
      laterButtonText: laterButtonText ?? this.laterButtonText,
      laterButtonStyle: laterButtonStyle ?? this.laterButtonStyle,
      dismissButtonText: dismissButtonText ?? this.dismissButtonText,
      dismissButtonStyle: dismissButtonStyle ?? this.dismissButtonStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      onAcceptButtonPressed:
          onAcceptButtonPressed ?? this.onAcceptButtonPressed,
      onLaterButtonPressed: onLaterButtonPressed ?? this.onLaterButtonPressed,
      onDismissButtonPressed:
          onDismissButtonPressed ?? this.onDismissButtonPressed,
    );
  }
}

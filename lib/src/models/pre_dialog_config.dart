import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

/// A function type that defines a custom pre-dialog builder.
///
/// The function takes the current [BuildContext] and a callback:
/// - [onApplyToAllPagesCheckboxChanged]: A callback to be invoked when the state
///   of the "Apply to all pages" checkbox changes. It will cache the user's choice
///   for future dialogs in the current session (reset in the next app-open).
///
/// The function returns a `FutureOr<PreDialogButtonType>` indicating the user's choice.
typedef CustomPreDialog = FutureOr<PreDialogButtonType> Function(
  BuildContext context,
  void Function(bool value) onApplyToAllPagesCheckboxChanged,
);

/// Configuration for the pre-dialog shown before starting a features tour.
class PreDialogConfig {
  /// Creates a new `PredialogConfig` instance with optional overrides.
  factory PreDialogConfig({
    /// Whether the pre-dialog should be displayed.
    bool? enabled,

    /// A custom dialog builder function. If provided, this will be used instead of
    /// the default dialog UI.
    ///
    /// If `onApplyToAllPagesCheckboxChanged` is provided, it will cache the user's choice
    /// for future dialogs in the current session (reset in the next app-open).
    ///
    /// *If you're using a custom dialog, all other configuration options will be ignored.*
    ///
    /// The function returns a `FutureOr<PreDialogButtonType>` indicating the user's choice.
    CustomPreDialog? customDialogBuilder,

    /// The background color of the dialog.
    Color? backgroundColor,

    /// The text color for the dialog content.
    Color? textColor,

    /// The title of the dialog.
    String? title,

    /// The label for the 'Apply to all pages' checkbox, used for semantics.
    String? applyToAllCheckboxLabel,

    /// The style for the 'Apply to all pages' label text.
    ///
    /// This also applies to the checkbox.
    TextStyle? applyToAllCheckboxLabelStyle,

    /// The message content of the dialog.
    String? content,

    /// The label for the accept button, which is also used for semantics.
    String? acceptButtonLabel,

    /// The styling for the accept button (typically an `FilledButton`).
    ButtonStyle? acceptButtonStyle,

    /// The label for the later button, which is also used for semantics.
    String? laterButtonLabel,

    /// The styling for the later button (typically a `TextButton`).
    ButtonStyle? laterButtonStyle,

    /// The label for the dismiss button, which is also used for semantics.
    String? dismissButtonLabel,

    /// The styling for the dismiss button (typically a `TextButton`).
    ButtonStyle? dismissButtonStyle,

    /// The radius of the dialog's corners, which makes it rounded.
    double? borderRadius,

    /// Callback when the accept button is pressed.
    VoidCallback? onAcceptButtonPressed,

    /// Callback when the later button is pressed.
    VoidCallback? onLaterButtonPressed,

    /// Callback when the dismiss button is pressed.
    VoidCallback? onDismissButtonPressed,
  }) {
    return global.copyWith(
      enabled: enabled,
      customDialogBuilder: customDialogBuilder,
      backgroundColor: backgroundColor,
      textColor: textColor,
      title: title,
      applyToAllPagesLabel: applyToAllCheckboxLabel,
      applyToAllCheckboxLabelStyle: applyToAllCheckboxLabelStyle,
      content: content,
      acceptButtonLabel: acceptButtonLabel,
      acceptButtonStyle: acceptButtonStyle,
      laterButtonLabel: laterButtonLabel,
      laterButtonStyle: laterButtonStyle,
      dismissButtonLabel: dismissButtonLabel,
      dismissButtonStyle: dismissButtonStyle,
      borderRadius: borderRadius,
      onAcceptButtonPressed: onAcceptButtonPressed,
      onLaterButtonPressed: onLaterButtonPressed,
      onDismissButtonPressed: onDismissButtonPressed,
    );
  }

  /// Creates a new instance of `PredialogConfig` with customizable options.
  PreDialogConfig._({
    this.enabled = true,
    this.title = 'Introduction',
    this.content =
        'This page has some new features that you might want to discover.\n\n'
            'Would you like to take a tour?',
    this.applyToAllPagesLabel = 'Apply to all pages',
    this.applyToAllCheckboxLabelStyle,
    this.acceptButtonLabel = 'Start Tour',
    this.acceptButtonStyle,
    this.laterButtonLabel = 'Later',
    this.laterButtonStyle,
    this.dismissButtonLabel = 'Dismiss',
    this.dismissButtonStyle,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.customDialogBuilder,
    this.onAcceptButtonPressed,
    this.onLaterButtonPressed,
    this.onDismissButtonPressed,
  });

  /// The global configuration instance.
  /// This allows for a shared default configuration across the app.
  static PreDialogConfig global = PreDialogConfig._();

  /// Whether the pre-dialog should be displayed.
  final bool enabled;

  /// The background color of the dialog.
  final Color? backgroundColor;

  /// The text color for the dialog content.
  final Color? textColor;

  /// The title of the dialog.
  final String title;

  /// The message content of the dialog.
  final String content;

  /// The label for the 'Apply to all pages' checkbox, used for semantics.
  final String applyToAllPagesLabel;

  /// The style for the 'Apply to all pages' label text.
  ///
  /// This also applies to the checkbox.
  final TextStyle? applyToAllCheckboxLabelStyle;

  /// The label for the accept button, which is also used for semantics.
  final String acceptButtonLabel;

  /// The styling for the accept button (typically an `ElevatedButton`).
  final ButtonStyle? acceptButtonStyle;

  /// The label for the later button, which is also used for semantics.
  final String laterButtonLabel;

  /// The styling for the later button (typically a `TextButton`).
  final ButtonStyle? laterButtonStyle;

  /// The label for the dismiss button, which is also used for semantics.
  final String dismissButtonLabel;

  /// The styling for the dismiss button (typically a `TextButton`).
  final ButtonStyle? dismissButtonStyle;

  /// The radius of the dialog's corners, which makes it rounded.
  final double borderRadius;

  /// A custom dialog builder function. If provided, this will be used instead of
  /// the default dialog UI.
  ///
  /// If `onApplyToAllPagesCheckboxChanged` is provided, it will cache the user's choice
  /// for future dialogs in the current session (reset in the next app-open).
  ///
  /// *If you're using a custom dialog, all other configuration options will be ignored.*
  ///
  /// The function returns a `FutureOr<PreDialogButtonType>` indicating the user's choice.
  final CustomPreDialog? customDialogBuilder;

  /// A callback that is triggered when the accept button is pressed.
  final VoidCallback? onAcceptButtonPressed;

  /// A callback that is triggered when the later button is pressed.
  final VoidCallback? onLaterButtonPressed;

  /// A callback that is triggered when the dismiss button is pressed.
  final VoidCallback? onDismissButtonPressed;

  /// Creates a new `PredialogConfig` instance based on the existing values.
  PreDialogConfig copyWith({
    bool? enabled,
    CustomPreDialog? customDialogBuilder,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? content,
    String? applyToAllPagesLabel,
    TextStyle? applyToAllCheckboxLabelStyle,
    String? acceptButtonLabel,
    ButtonStyle? acceptButtonStyle,
    String? laterButtonLabel,
    ButtonStyle? laterButtonStyle,
    String? dismissButtonLabel,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
    VoidCallback? onAcceptButtonPressed,
    VoidCallback? onLaterButtonPressed,
    VoidCallback? onDismissButtonPressed,
  }) {
    return PreDialogConfig._(
      enabled: enabled ?? this.enabled,
      customDialogBuilder: customDialogBuilder ?? this.customDialogBuilder,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      title: title ?? this.title,
      content: content ?? this.content,
      applyToAllPagesLabel: applyToAllPagesLabel ?? this.applyToAllPagesLabel,
      applyToAllCheckboxLabelStyle:
          applyToAllCheckboxLabelStyle ?? this.applyToAllCheckboxLabelStyle,
      acceptButtonLabel: acceptButtonLabel ?? this.acceptButtonLabel,
      acceptButtonStyle: acceptButtonStyle ?? this.acceptButtonStyle,
      laterButtonLabel: laterButtonLabel ?? this.laterButtonLabel,
      laterButtonStyle: laterButtonStyle ?? this.laterButtonStyle,
      dismissButtonLabel: dismissButtonLabel ?? this.dismissButtonLabel,
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

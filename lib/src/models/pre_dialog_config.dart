import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

/// Configuration for the pre-dialog shown before starting a features tour.
@Deprecated('Use PreDialogConfig instead')
typedef PredialogConfig = PreDialogConfig;

/// Configuration for the pre-dialog shown before starting a features tour.
class PreDialogConfig {
  /// Creates a new `PredialogConfig` instance with optional overrides.
  factory PreDialogConfig({
    bool? enabled,
    @Deprecated('Use customDialog instead')
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    FutureOr<PreDialogButtonType> Function(
      BuildContext context,
      void Function(bool isChecked) updateApplyToAllPagesState,
    )? customDialog,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    @Deprecated('Use applyToAllPagesLabel instead') String? applyToAllPagesText,
    String? applyToAllPagesLabel,
    Color? applyToAllPagesTextColor,
    String? content,
    @Deprecated('Use acceptButtonLabel instead') Text? acceptButtonText,
    String? acceptButtonLabel,
    ButtonStyle? acceptButtonStyle,
    @Deprecated('Use laterButtonLabel instead') Text? laterButtonText,
    String? laterButtonLabel,
    ButtonStyle? laterButtonStyle,
    @Deprecated('Use dismissButtonLabel instead') Text? dismissButtonText,
    String? dismissButtonLabel,
    ButtonStyle? dismissButtonStyle,
    double? borderRadius,
    VoidCallback? onAcceptButtonPressed,
    VoidCallback? onLaterButtonPressed,
    VoidCallback? onDismissButtonPressed,
  }) {
    return global.copyWith(
      enabled: enabled,
      // TODO(lamnhan066): Remove deprecated field in the next major release
      // ignore: deprecated_member_use_from_same_package
      modifiedDialogResult: modifiedDialogResult,
      customDialog: customDialog,
      backgroundColor: backgroundColor,
      textColor: textColor,
      title: title,
      applyToAllPagesLabel: applyToAllPagesLabel ?? applyToAllPagesText,
      applyToAllPagesTextColor: applyToAllPagesTextColor,
      content: content,
      acceptButtonLabel: acceptButtonLabel ?? acceptButtonText?.data,
      acceptButtonStyle: acceptButtonStyle,
      laterButtonLabel: laterButtonLabel ?? laterButtonText?.data,
      laterButtonStyle: laterButtonStyle,
      dismissButtonLabel: dismissButtonLabel ?? dismissButtonText?.data,
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
    this.applyToAllPagesTextColor,
    this.acceptButtonLabel = 'Okay',
    this.acceptButtonStyle,
    this.laterButtonLabel = 'Later',
    this.laterButtonStyle,
    this.dismissButtonLabel = 'Dismiss',
    this.dismissButtonStyle,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    // TODO(lamnhan066): Remove deprecated field in the next major release
    // ignore: deprecated_consistency
    this.modifiedDialogResult,
    this.customDialog,
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

  /// The color of the 'Apply to all pages' label text, which is also applied to the checkbox.
  ///
  /// The default is [textColor]; otherwise, it falls back to the primary color.
  final Color? applyToAllPagesTextColor;

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

  /// A custom function to override the default dialog behavior.
  @Deprecated('Use customDialog instead')
  final FutureOr<bool> Function(BuildContext context)? modifiedDialogResult;

  /// A custom dialog builder function. If provided, this will be used instead of
  /// the default dialog UI.
  ///
  /// The function takes the current [BuildContext] and an `updateApplyToAllPagesState`
  /// callback to update the "Apply to all pages" checkbox state, and returns
  /// a `FutureOr<PreDialogButtonType>`.
  final FutureOr<PreDialogButtonType> Function(
    BuildContext context,
    void Function(bool isChecked) updateApplyToAllPagesState,
  )? customDialog;

  /// A callback that is triggered when the accept button is pressed.
  final VoidCallback? onAcceptButtonPressed;

  /// A callback that is triggered when the later button is pressed.
  final VoidCallback? onLaterButtonPressed;

  /// A callback that is triggered when the dismiss button is pressed.
  final VoidCallback? onDismissButtonPressed;

  /// Creates a new `PredialogConfig` instance based on the existing values.
  PreDialogConfig copyWith({
    bool? enabled,
    @Deprecated('Use customDialog instead')
    FutureOr<bool> Function(BuildContext)? modifiedDialogResult,
    FutureOr<PreDialogButtonType> Function(
      BuildContext context,
      void Function(bool isChecked) updateApplyToAllPagesState,
    )? customDialog,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? content,
    String? applyToAllPagesLabel,
    Color? applyToAllPagesTextColor,
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
      // TODO(lamnhan066): Remove deprecated field in the next major release
      // ignore: deprecated_member_use_from_same_package
      modifiedDialogResult: modifiedDialogResult ?? this.modifiedDialogResult,
      customDialog: customDialog ?? this.customDialog,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      title: title ?? this.title,
      content: content ?? this.content,
      applyToAllPagesLabel: applyToAllPagesLabel ?? this.applyToAllPagesLabel,
      applyToAllPagesTextColor:
          applyToAllPagesTextColor ?? this.applyToAllPagesTextColor,
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

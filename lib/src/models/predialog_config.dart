import 'dart:async';

import 'package:flutter/material.dart';

class PredialogConfig {
  /// Global configuration
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

  /// [enabled] to enable or disable the Predialog
  final bool enabled;

  /// [backgroundColor] is the background color of the dialog
  final Color backgroundColor;

  /// [textColor] is the color of all the text
  final Color textColor;

  /// [title] is the title of the dialog, default is 'Introduction'
  final String title;

  /// [content] is the content, default is "This page has some new features that you might want to discover.\n\nWould you like to take a tour?"
  final String content;

  /// [applyToAllPagesText] is the text for doNotAskAgain checkbox
  final String applyToAllPagesText;

  /// Accept the action
  final Text acceptButtonText;

  /// Style of the accept button [ElevatedButton]
  final ButtonStyle? acceptButtonStyle;

  /// Ask again in the next time
  final Text laterButtonText;

  /// Style of the later button [TextButton]
  final ButtonStyle? laterButtonStyle;

  /// Don't show the tour even if a new one is added
  final Text dismissButtonText;

  /// Style of the dismiss button [TextButton]
  final ButtonStyle? dismissButtonStyle;

  /// [borderRadius] is the radius of the dialog border
  final double borderRadius;

  /// [modifiedDialogResult] is the value the return from your modified dialog
  /// If this variable is set, others will be ignored.
  final FutureOr<bool> Function(BuildContext context)? modifiedDialogResult;

  /// Create a new Predialog base on the [global] values
  ///
  /// [enabled] to enable or disable the Predialog. Default is `true`.
  ///
  /// [title] is the title of the dialog, default is 'Introduction'
  ///
  /// [content] is the content, default is "This page has some new features that you might want to discover.\n\nWould you like to take a tour?"
  ///
  /// [applyToAllPagesText] is the text for applyToAllPages checkbox. Default is 'Do not ask again this time'.
  ///
  /// [acceptButtonText] Accept the action
  ///
  /// [acceptButtonStyle] Style of the accept button [ElevatedButton]
  ///
  /// [laterButtonText] Ask again in the next time
  ///
  /// [laterButtonStyle] Style of the later button [TextButton]
  ///
  /// [dismissButtonText] Do not show and don't ask again
  ///
  /// [dismissButtonStyle] Style of the dismiss button [TextButton]
  ///
  /// [borderRadius] is the radius of the dialog border. Default is 12.
  ///
  /// [backgroundColor] is the background color of the dialog. Default is Colors.white.
  ///
  /// [textColor] is the color of all the text. Default is Colors.black.
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
      global.copyWith(
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

  /// Create a new Predialog base on this values
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

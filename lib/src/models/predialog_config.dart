import 'dart:async';

import 'package:flutter/material.dart';

class PredialogConfig {
  /// Global configuration
  static PredialogConfig global = PredialogConfig._();

  /// This is the configuration for Predialog.
  ///
  /// [enabled] to enable or disable the Predialog
  ///
  /// [modifiedDialogResult] is the value the return from your modified dialog
  /// If this variable is set, others will be ignored.
  ///
  /// [title] is the title of the dialog, default is 'Introduction'
  ///
  /// [content] is the content, default is "This page has some new features that you might want to discover.\n\nWould you like to take a tour?"
  ///
  /// [applyToAllPagesText] is the text for doNotAskAgain checkbox
  ///
  /// [acceptButtonText] and [cancelButtonText] are the text of the corresponding buttons
  ///
  /// [borderRadius] is the radius of the dialog border
  ///
  /// [backgroundColor] is the background color of the dialog
  ///
  /// [textColor] is the color of all the text
  PredialogConfig._({
    this.enabled = true,
    this.title = 'Introduction',
    this.content =
        'This page has some new features that you might want to discover.\n\n'
            'Would you like to take a tour?',
    this.applyToAllPagesText = 'Apply to all pages',
    this.acceptButtonText = 'Yes',
    this.cancelButtonText = 'No',
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

  /// [acceptButtonText] and [cancelButtonText] are the text of the corresponding buttons
  final String acceptButtonText;

  /// [acceptButtonText] and [cancelButtonText] are the text of the corresponding buttons
  final String cancelButtonText;

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
  /// [acceptButtonText] and [cancelButtonText] are the text of the corresponding buttons
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
    String? acceptButtonText,
    String? cancelButtonText,
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
        cancelButtonText: cancelButtonText,
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
    String? acceptButtonText,
    String? cancelButtonText,
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
      cancelButtonText: cancelButtonText ?? this.cancelButtonText,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

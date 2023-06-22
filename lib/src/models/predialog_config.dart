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
  /// [yesButtonText] and [noButtonText] are the text of the corresponding buttons
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
    this.yesButtonText = 'Yes',
    this.noButtonText = 'No',
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.modifiedDialogResult,
  });

  final bool enabled;
  final Color backgroundColor;
  final Color textColor;
  final String title;
  final String content;
  final String applyToAllPagesText;
  final String yesButtonText;
  final String noButtonText;
  final double borderRadius;
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
  /// [yesButtonText] and [noButtonText] are the text of the corresponding buttons
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
      PredialogConfig._(
        enabled: enabled ?? global.enabled,
        modifiedDialogResult:
            modifiedDialogResult ?? global.modifiedDialogResult,
        backgroundColor: backgroundColor ?? global.backgroundColor,
        textColor: textColor ?? global.textColor,
        title: title ?? global.title,
        applyToAllPagesText: applyToAllPagesText ?? global.applyToAllPagesText,
        content: content ?? global.content,
        yesButtonText: acceptButtonText ?? global.yesButtonText,
        noButtonText: cancelButtonText ?? global.noButtonText,
        borderRadius: borderRadius ?? global.borderRadius,
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
      yesButtonText: acceptButtonText ?? yesButtonText,
      noButtonText: cancelButtonText ?? noButtonText,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

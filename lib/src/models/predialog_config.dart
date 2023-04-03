import 'package:flutter/material.dart';

class PredialogConfig {
  /// Global configuration
  static PredialogConfig global = PredialogConfig._();

  /// This is the configuration for Predialog.
  ///
  /// [enabled] to enable or disable the Predialog
  ///
  /// [title] is the title of the dialog, default is 'Introduction'
  ///
  /// [content] is the content, default is "This page has some new features that you might want to discover.\n\nWould you like to take a tour?"
  ///
  /// [doNotAskAgainText] is the text for doNotAskAgain checkbox
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
    this.doNotAskAgainText = 'Do not ask again this time',
    this.yesButtonText = 'Yes',
    this.noButtonText = 'No',
    this.borderRadius = 12,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });

  final bool enabled;
  final Color backgroundColor;
  final Color textColor;
  final String title;
  final String content;
  final String doNotAskAgainText;
  final String yesButtonText;
  final String noButtonText;
  final double borderRadius;

  /// Create a new Predialog base on the [global] values
  factory PredialogConfig.copyWith({
    bool? enabled,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? doNotAskAgainText,
    String? content,
    String? acceptButtonText,
    String? cancelButtonText,
    double? borderRadius,
  }) =>
      PredialogConfig._(
        enabled: enabled ?? global.enabled,
        backgroundColor: backgroundColor ?? global.backgroundColor,
        textColor: textColor ?? global.textColor,
        title: title ?? global.title,
        doNotAskAgainText: doNotAskAgainText ?? global.doNotAskAgainText,
        content: content ?? global.content,
        yesButtonText: acceptButtonText ?? global.yesButtonText,
        noButtonText: cancelButtonText ?? global.noButtonText,
        borderRadius: borderRadius ?? global.borderRadius,
      );

  /// Create a new Predialog base on this values
  PredialogConfig copyWith({
    bool? enabled,
    Color? backgroundColor,
    Color? textColor,
    String? title,
    String? content,
    String? doNotAskAgainText,
    String? acceptButtonText,
    String? cancelButtonText,
    double? borderRadius,
  }) {
    return PredialogConfig._(
      enabled: enabled ?? this.enabled,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      title: title ?? this.title,
      content: content ?? this.content,
      doNotAskAgainText: doNotAskAgainText ?? this.doNotAskAgainText,
      yesButtonText: acceptButtonText ?? yesButtonText,
      noButtonText: cancelButtonText ?? noButtonText,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}

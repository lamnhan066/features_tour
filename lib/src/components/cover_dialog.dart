import 'package:flutter/material.dart';

import '../features_tour.dart';

OverlayEntry? _coverOverlay;

/// Show the cover to avoid user tapping the screen.
void showCover(BuildContext context, Color? color) {
  if (!context.mounted) {
    printDebug(
        () => 'Cannot show the cover because the build context is not mounted');
    return;
  }

  _coverOverlay = OverlayEntry(builder: (ctx) {
    return Material(
      color: color ?? Colors.transparent,
      child: const PopScope(
        canPop: false,
        child: SizedBox.shrink(),
      ),
    );
  });

  Overlay.of(context, rootOverlay: true).insert(_coverOverlay!);
}

/// Hide the cover to let the user able to tap the screen.
void hideCover(BuildContext context) {
  if (!context.mounted) {
    printDebug(
        () => 'Cannot hide the cover because the build context is not mounted');
    return;
  }

  _coverOverlay?.remove();
  _coverOverlay = null;
}

import 'package:flutter/material.dart';

OverlayEntry? _coverOverlay;

/// Show the cover to avoid user tapping the screen.
void showCover(
  BuildContext context,
  Color color,
  void Function(String log)? printDebug,
) {
  if (!context.mounted) {
    printDebug?.call(
      'Cannot show the cover because the build context is not mounted',
    );
    return;
  }

  if (_coverOverlay != null) {
    printDebug?.call('The cover is already shown');
    return;
  }

  printDebug?.call('Showing the cover');

  _coverOverlay = OverlayEntry(
    builder: (ctx) {
      return Material(
        color: color,
        child: const SizedBox.shrink(),
      );
    },
  );

  Overlay.of(context, rootOverlay: true).insert(_coverOverlay!);
}

/// Hides the cover to allow the user to tap the screen.
void hideCover(void Function(String log)? printDebug) {
  if (_coverOverlay == null) {
    printDebug?.call('The cover is already hidden');
    return;
  }
  printDebug?.call('Hiding the cover');

  _coverOverlay?.remove();
  _coverOverlay = null;
}

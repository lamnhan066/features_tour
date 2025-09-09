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
        'Cannot show the cover because the build context is not mounted');
    return;
  }

  if (_coverOverlay != null) {
    printDebug?.call('The cover is already shown');
    return;
  }

  _coverOverlay = OverlayEntry(builder: (ctx) {
    return Material(
      color: color,
      child: const PopScope(
        canPop: false,
        child: SizedBox.shrink(),
      ),
    );
  });

  Overlay.of(context, rootOverlay: true).insert(_coverOverlay!);
}

/// Hide the cover to let the user able to tap the screen.
void hideCover(BuildContext context, void Function(String log)? printDebug) {
  if (!context.mounted) {
    printDebug?.call(
      'Cannot hide the cover because the build context is not mounted',
    );
    return;
  }

  _coverOverlay?.remove();
  _coverOverlay = null;
}

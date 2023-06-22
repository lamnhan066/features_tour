import 'package:flutter/material.dart';

import '../../features_tour.dart';

DialogRoute? _coverDialog;

/// Show the cover to avoid user tapping the screen
void showCover(BuildContext context) {
  if (!context.mounted) {
    printDebug(
        'Cannot show the cover because the build context is not mounted');
    return;
  }

  _coverDialog = DialogRoute(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    barrierColor: Colors.transparent,
    builder: (context) {
      return WillPopScope(
        onWillPop: () => Future.value(false),
        child: const SizedBox.shrink(),
      );
    },
  );

  Navigator.of(context).push(_coverDialog!);
}

/// Hide the cover to let the user able to tap the screen
void hideCover(BuildContext context) {
  if (!context.mounted) {
    printDebug(
        'Cannot hide the cover because the build context is not mounted');
    return;
  }
  if (_coverDialog != null) {
    Navigator.of(context).removeRoute(_coverDialog!);
  }
  _coverDialog = null;
}

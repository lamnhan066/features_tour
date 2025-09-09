import 'dart:async';

import 'package:features_tour/src/features_tour.dart';
import 'package:features_tour/src/models/predialog_button_type.dart';
import 'package:features_tour/src/models/predialog_config.dart';
import 'package:flutter/material.dart';

/// Caches the last "Do not ask again" selection.
PredialogButtonType? _applyToAllPages;

/// FOR TESTING ONLY: Resets the cached "Do not ask again" selection.
@visibleForTesting
void resetPredialog() {
  _applyToAllPages = null;
}

/// Displays a pre-dialog with a configurable UI.
Future<PredialogButtonType> predialog(
  BuildContext context,
  PredialogConfig config,
  FutureOr<void> Function() onShownPreDialog,
  FutureOr<void> Function(PredialogButtonType type) onAppliedToAllPages,
  void Function(String log)? printDebug,
) async {
  // Returns the cached selection if "Do not ask again" was checked previously.
  if (_applyToAllPages != null) {
    printDebug?.call('Returning cached result: $_applyToAllPages.');
    await onAppliedToAllPages(_applyToAllPages!);
    return _applyToAllPages!;
  }

  var isChecked = false;
  final completer = Completer<PredialogButtonType>();

  void complete(PredialogButtonType type) {
    if (!completer.isCompleted) completer.complete(type);
  }

  final overlayEntry = OverlayEntry(
    builder: (context) => Material(
      color: Colors.black54,
      child: AlertDialog(
        title: Text(config.title, style: TextStyle(color: config.textColor)),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.content,
              style: TextStyle(color: config.textColor, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            _CheckboxRow(
              text: config.applyToAllPagesText,
              baseTextColor: config.textColor,
              checkboxTextColor: config.applyToAllPagesTextColor,
              onChanged: (value) => isChecked = value,
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius)),
        actions: [
          ElevatedButton(
            onPressed: () => complete(PredialogButtonType.accept),
            style: config.acceptButtonStyle,
            child: config.acceptButtonText,
          ),
          TextButton(
            onPressed: () => complete(PredialogButtonType.later),
            style: config.laterButtonStyle,
            child: config.laterButtonText,
          ),
          TextButton(
            onPressed: () => complete(PredialogButtonType.dismiss),
            style: config.dismissButtonStyle,
            child: config.dismissButtonText,
          ),
        ],
      ),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(overlayEntry);

  await onShownPreDialog();

  try {
    final result = await completer.future;

    if (isChecked) {
      printDebug?.call('Updating global pre-dialog selection.');
      _applyToAllPages = result;

      if (result == PredialogButtonType.dismiss) {
        printDebug?.call('Disabling all future introduction tours.');

        // TODO(lamnhan066): Handle tour-specific dismissals better.
        await DismissAllTourStorage.setDismissAllTours(true);
      }
    }

    return result;
  } catch (e, stackTrace) {
    completer.completeError(e, stackTrace);
    rethrow;
  } finally {
    overlayEntry.remove();
  }
}

/// A stateful checkbox row with text for "Apply to all pages".
class _CheckboxRow extends StatefulWidget {
  const _CheckboxRow({
    required this.text,
    required this.baseTextColor,
    required this.checkboxTextColor,
    required this.onChanged,
  });
  final String text;
  final Color? baseTextColor;
  final Color? checkboxTextColor;
  final ValueChanged<bool> onChanged;

  @override
  State<_CheckboxRow> createState() => _CheckboxRowState();
}

class _CheckboxRowState extends State<_CheckboxRow> {
  bool isChecked = false;

  void _toggleCheckbox() {
    setState(() {
      isChecked = !isChecked;
    });
    widget.onChanged(isChecked);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.checkboxTextColor ?? widget.baseTextColor;
    return FittedBox(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: Checkbox.width,
            height: Checkbox.width,
            child: Checkbox(
              value: isChecked,
              activeColor: color,
              side: color != null ? BorderSide(color: color, width: 1.5) : null,
              onChanged: (_) => _toggleCheckbox(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleCheckbox,
            child: Text(
              widget.text,
              style: TextStyle(color: color, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

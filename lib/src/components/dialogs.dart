import 'dart:async';

import 'package:features_tour/src/models/button_types.dart';
import 'package:flutter/material.dart';

import '../features_tour.dart';
import '../models/predialog_config.dart';

/// Caches the last "Do not ask again" selection.
ButtonTypes? _applyToAllPages;

/// Displays a pre-dialog with a configurable UI.
Future<ButtonTypes> predialog(
  BuildContext context,
  PredialogConfig config,
) async {
  // Return cached selection if "Do not ask again" was checked previously.
  if (_applyToAllPages != null) {
    printDebug(() => 'Returning cached result: $_applyToAllPages');
    return _applyToAllPages!;
  }

  bool isChecked = false;
  final completer = Completer<ButtonTypes>();

  void complete(ButtonTypes type) {
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
            Text(config.content,
                style: TextStyle(color: config.textColor, fontSize: 13.5)),
            const SizedBox(height: 20),
            _CheckboxRow(
              text: config.applyToAllPagesText,
              textColor: config.textColor,
              onChanged: (value) => isChecked = value,
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(config.borderRadius)),
        actions: [
          ElevatedButton(
            onPressed: () => complete(ButtonTypes.accept),
            style: config.acceptButtonStyle,
            child: config.acceptButtonText,
          ),
          TextButton(
            onPressed: () => complete(ButtonTypes.later),
            style: config.laterButtonStyle,
            child: config.laterButtonText,
          ),
          TextButton(
            onPressed: () => complete(ButtonTypes.dismiss),
            style: config.dismissButtonStyle,
            child: config.dismissButtonText,
          ),
        ],
      ),
    ),
  );

  Overlay.of(context, rootOverlay: true).insert(overlayEntry);

  try {
    final result = await completer.future;

    if (isChecked) {
      printDebug(() => 'Updating global pre-dialog selection');
      _applyToAllPages = result;

      if (result == ButtonTypes.dismiss) {
        printDebug(() => 'Disabling all future introduction tours.');

        // TODO: Handle tour-specific dismissals better.
        SharedPrefs.setDismissAllTours(true);
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
  final String text;
  final Color textColor;
  final ValueChanged<bool> onChanged;

  const _CheckboxRow({
    required this.text,
    required this.textColor,
    required this.onChanged,
  });

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
    return FittedBox(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Checkbox(
            value: isChecked,
            side: BorderSide(color: widget.textColor, width: 1.5),
            onChanged: (_) => _toggleCheckbox(),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _toggleCheckbox,
            child: Text(widget.text,
                style: TextStyle(color: widget.textColor, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

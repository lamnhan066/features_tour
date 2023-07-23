import 'package:flutter/material.dart';

import '../features_tour.dart';
import '../models/predialog_config.dart';

/// Save the state of the doNotAskAgain checkbox
bool? _applyToAllPages;

/// Show the predialog with specific configuration
Future<bool?> predialog(BuildContext context, PredialogConfig config) async {
  // If `_dontAskAgainResult` is not null, the `doNotAksAgain` is checked
  // so just return the result.
  if (_applyToAllPages != null) {
    printDebug(
        'Apply to all screens is checked in the previous dialog, return previous result: $_applyToAllPages');
    return _applyToAllPages;
  }

  bool checkbox = false;
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useSafeArea: false,
    barrierColor: Colors.black54,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          config.title,
          style: TextStyle(color: config.textColor),
        ),
        contentPadding:
            const EdgeInsets.only(bottom: 8, top: 20, left: 24, right: 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.content,
              style: TextStyle(color: config.textColor, fontSize: 13.5),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: checkbox,
                        side: BorderSide(color: config.textColor, width: 1.5),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              checkbox = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      child: Text(
                        config.applyToAllPagesText,
                        style: TextStyle(
                          color: config.textColor,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          checkbox = !checkbox;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(config.borderRadius),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            style: config.acceptButtonStyle,
            child: config.acceptButtonText,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            style: config.laterButtonStyle,
            child: config.laterButtonText,
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            style: config.dismissButtonStyle,
            child: config.dismissButtonText,
          ),
        ],
      );
    },
  );

  // If the dontAskAgain checkbox is checked, the global configuration will be
  // updated
  if (checkbox) {
    printDebug(
        'applyToAllPages checkbox is checked => Update global predialog configuration');
    _applyToAllPages = result;

    if (result == null) {
      printDebug('All pages will be disabled to show introduction');

      // TODO: Find another way to dismiss and apply to all. Current: all the FeaturesTour even a new one will be all dismissed.
      SharedPrefs.setDismissAllTours(true);
    }
  }

  return result;
}

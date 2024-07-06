part of '../features_tour.dart';

/// Print debug log.
void printDebug(Object? Function() log) {
  if (!FeaturesTour._debugLog) return;

  debugPrint('[Features Tour] ${log()}');
}

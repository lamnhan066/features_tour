part of '../features_tour.dart';

/// Print debug log.
void printDebug(Object? object) {
  if (!FeaturesTour._debugLog) return;

  debugPrint('[Features Tour] $object');
}

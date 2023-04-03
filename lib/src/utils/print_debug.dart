import 'package:flutter/foundation.dart';

/// Print debug log
void printDebug(Object? object) {
  if (kReleaseMode) return;

  debugPrint('[Features Tour] $object');
}

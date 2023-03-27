import 'package:flutter/foundation.dart';

void printDebug(Object? object) {
  if (kReleaseMode) return;

  debugPrint('[Features Tour] $object');
}

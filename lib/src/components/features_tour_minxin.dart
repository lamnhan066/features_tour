import 'package:features_tour/src/models/instruction_result.dart';
import 'package:flutter/material.dart';

mixin FeaturesTourStateMixin {
  double get index => throw UnimplementedError();

  double? get waitForIndex => throw UnimplementedError();

  Duration get waitForTimeout => throw UnimplementedError();

  BuildContext get currentContext => throw UnimplementedError();

  Future<IntroduceResult> showIntroduce() => throw UnimplementedError();
}

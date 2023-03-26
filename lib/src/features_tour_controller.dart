part of 'features_tour.dart';

mixin _FeaturesTourStateMixin {
  void featuresTourInitial() {
    assert(() {
      for (final controller in FeaturesTour._controllers[pageName]!) {
        if (controller.index == index) {
          return false;
        }
      }

      return true;
    }(), '`index` = $index is dupplicated!');

    // FeaturesTour._controllers.add(this);
    FeaturesTour._controllers[pageName]!.add(this);
  }

  void featuresTourDispose() {
    // FeaturesTour._controllers.remove(this);
    FeaturesTour._controllers[pageName]!.remove(this);
  }

  @protected
  int get index => throw UnimplementedError();

  @protected
  String get name => throw UnimplementedError();

  @protected
  String? get pageName => throw UnimplementedError();

  @protected
  Future<void> showIntrodure() => throw UnimplementedError();
}

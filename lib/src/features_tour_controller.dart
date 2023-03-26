part of 'features_tour.dart';

mixin _FeaturesTourController {
  void featuresTourInitial() {
    assert(() {
      for (final controller in FeaturesTour._controllers) {
        if (controller.index == index) {
          return false;
        }
      }

      return true;
    }(), '`index` = $index is dupplicated!');

    FeaturesTour._controllers.add(this);
  }

  void featuresTourDispose() {
    FeaturesTour._controllers.remove(this);
  }

  @protected
  int get index => throw UnimplementedError();

  @protected
  String get name => throw UnimplementedError();

  @protected
  Future<void> showIntrodure() => throw UnimplementedError();
}

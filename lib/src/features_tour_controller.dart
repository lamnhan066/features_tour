part of 'features_tour.dart';

mixin FeaturesTourController {
  /// Prefix of this package
  static String prefix = 'FeaturesTour_';

  static int _privateIndex = 0;
  static int get _autoIndex {
    while (_isDuppicated(_privateIndex)) {
      _privateIndex++;
    }

    return ++_privateIndex;
  }

  static bool _isDuppicated(int index) {
    for (final controller in _controllers) {
      if (controller._index == index) {
        return true;
      }
    }

    return false;
  }

  /// Internal list of the controllers
  static final List<FeaturesTourController> _controllers = [];

  /// Start the tour. This packaga automatically save the state of the widget,
  /// so it will skip the showed widget.
  static Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();

    _controllers.sort((a, b) => a._index.compareTo(b._index));
    for (final controller in _controllers) {
      final key = '$prefix${controller._name}';

      if (prefs.getBool(key) != true) {
        await controller._showIntrodure();
      }

      await prefs.setBool(key, true);
    }
  }

  // static Future<void> next() async {}
  // static Future<void> back() async {}
  // static Future<void> close() async {}

  void _featuresTourInitial() {
    assert(() {
      for (final controller in _controllers) {
        if (controller._index == _index) {
          debugPrint('[FeaturesTour] `index` = $_index is dupplicated!');
          return false;
        }
      }

      return true;
    }());

    _controllers.add(this);
  }

  void _featuresTourDispose() {
    _controllers.remove(this);
  }

  @protected
  int get _index => _autoIndex;

  @protected
  String get _name => _index.toString();

  @protected
  Future<void> _showIntrodure() async {}
}

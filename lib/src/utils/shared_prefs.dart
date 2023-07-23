part of '../features_tour.dart';

class SharedPrefs {
  static const String _dismissAllTours = 'DismissAllTours';

  static Future<void> setDismissAllTours(bool value) =>
      _setPrefSetting(_dismissAllTours, value);

  static Future<bool?> getDismissAllTours() async {
    final result = await _getPrefSetting(_dismissAllTours);
    return result as bool?;
  }

  static Future<void> _setPrefSetting(String key, Object value) async {
    key = '${FeaturesTour._prefix}_$key';
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      prefs.setBool(key, value);
    } else if (value is String) {
      prefs.setString(key, value);
    } else if (value is int) {
      prefs.setInt(key, value);
    } else if (value is double) {
      prefs.setDouble(key, value);
    } else {
      throw UnsupportedError('Khong ho tro kieu ${value.runtimeType}');
    }
  }

  static Future<Object?> _getPrefSetting(String key) async {
    key = '${FeaturesTour._prefix}_$key';
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }
}

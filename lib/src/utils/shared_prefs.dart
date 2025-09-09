part of '../features_tour.dart';

/// Utility class for managing shared preferences related to the Features Tour.
class SharedPrefs {
  static const String _dismissAllTours = 'DismissAllTours';
  static SharedPreferences? _instance;

  static Future<SharedPreferences> _getPrefsInstance() async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Sets whether all tours should be dismissed.
  static Future<void> setDismissAllTours(bool value) =>
      _setPrefSetting(_dismissAllTours, value);

  /// Gets whether all tours have been dismissed.
  static Future<bool> getDismissAllTours() async {
    final result = await _getPrefSetting(_dismissAllTours);
    return result as bool? ?? false;
  }

  /// Sets a preference setting.
  static Future<void> _setPrefSetting(String key, Object value) async {
    key = '${FeaturesTour._prefix}_$key';
    final prefs = await _getPrefsInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      throw UnsupportedError('This is unsupported type: ${value.runtimeType}');
    }
  }

  /// Gets a preference setting.
  static Future<Object?> _getPrefSetting(String key) async {
    key = '${FeaturesTour._prefix}_$key';
    final prefs = await _getPrefsInstance();
    return prefs.get(key);
  }
}

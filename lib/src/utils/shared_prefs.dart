part of '../features_tour.dart';

/// Utility class for managing shared preferences related to the Features Tour.
class DismissAllTourStorage {
  static const String _dismissAllTours = 'DismissAllTours';
  static SharedPreferences? _instance;

  static Future<SharedPreferences> _getPrefsInstance() async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// Sets whether all tours should be dismissed.
  static Future<void> setDismissAllTours(bool value) async {
    final key = '${FeaturesTour._prefix}_$_dismissAllTours';
    final prefs = await _getPrefsInstance();
    await prefs.setBool(key, value);
  }

  /// Gets whether all tours have been dismissed.
  static Future<bool> getDismissAllTours() async {
    final key = '${FeaturesTour._prefix}_$_dismissAllTours';
    final prefs = await _getPrefsInstance();
    return prefs.getBool(key) ?? false;
  }
}

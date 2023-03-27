part of 'features_tour.dart';

class FeaturesTourController {
  /// Internal preferences
  static SharedPreferences? _prefs;

  /// Create a controller for FeaturesTour with unique [pageName]. This value is
  /// used to store the state of the current page, so please do not change it
  /// if you don't want to re-show the instructions.
  FeaturesTourController(this.pageName) {
    FeaturesTour._controllers.add(this);
  }

  /// Name of this page
  final String pageName;

  /// Internal list of the controllers
  final List<FeaturesTourStateMixin> _states = [];

  /// Register the current FeaturesTour state
  void _register(FeaturesTourStateMixin state) => _states.add(state);

  /// Unregister the current FeaturesTour state
  void _unregister(FeaturesTourStateMixin state) => _states.remove(state);

  /// Start the tour. This packaga automatically save the state of the widget,
  /// so it will skip the showed widget.
  ///
  /// Please note that the page navigation may affect this widget, so if you add
  /// this method to `initState`, you should delay for a second before calling this.
  ///
  /// Ex:
  /// ``` dart
  /// void initState() {
  ///   Timer(Duration(seconds:1), () {
  ///     tourController.start();
  ///   });
  /// }
  /// ```
  Future<void> start({
    /// If this `context` is not null, it will be used to wait for the page
    /// transition to complete before showing the instructions.
    BuildContext? context,

    /// Forces show up on the instructions.
    bool isDebug = false,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (context != null && context.mounted) {
      printDebug('Waiting for the page transition to complete..');
      final modalRoute = ModalRoute.of(context)?.animation;
      Completer completer = Completer();

      if (modalRoute == null ||
          modalRoute.isCompleted ||
          modalRoute.isDismissed) {
        if (!completer.isCompleted) completer.complete();
      } else {
        modalRoute.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) {
            if (!completer.isCompleted) completer.complete();
          }
        });
      }

      await completer.future;
      printDebug('Page transition completed.');
    }
    printDebug('Start the tour');

    _states.sort((a, b) => a.index.compareTo(b.index));
    // while (_states.isNotEmpty) {
    //   // Skip this tour if it's skipped
    //   if (_states.isEmpty) {
    //     printDebug('This page $pageName is skipped');
    //     break;
    //   }

    //   final state = _states.removeAt(0);
    //   // ignore: use_build_context_synchronously
    //   final key = FeaturesTour._getPrefKey(pageName, state);

    //   printDebug('Start widget with key $key');

    //   if (_prefs!.getBool(key) != true || isDebug) {
    //     await state.showIntrodure();
    //   }

    //   await _prefs!.setBool(key, true);
    //   _unregister(state);
    // }
    for (final state in _states) {
      // ignore: use_build_context_synchronously
      final key = FeaturesTour._getPrefKey(pageName, state);

      printDebug('Start widget with key $key');

      if (_prefs!.getBool(key) != true || isDebug) {
        await state.showIntrodure();
      }
    }

    await removePage(markAsShowed: !isDebug);

    printDebug('This tour has been completed');
  }

  /// Removes all controllers for specific `pageName`
  Future<void> removePage({bool markAsShowed = true}) async {
    if (_states.isEmpty) {
      printDebug('Page $pageName has already been removed');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    while (_states.isNotEmpty) {
      final state = _states.removeAt(0);
      if (markAsShowed) {
        // ignore: use_build_context_synchronously
        final key = FeaturesTour._getPrefKey(pageName, state);
        await _prefs!.setBool(key, true);
      }
      _unregister(state);
    }

    _states.clear();

    printDebug('Remove page: $pageName');
  }

  /// Removes all controllers for all pages
  Future<void> removeAll({bool markAsShowed = true}) =>
      FeaturesTour.removeAll(markAsShowed: markAsShowed);
}

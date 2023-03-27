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

  int _index = 0;
  int get autoIndex => _index++;

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
  /// WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  ///   tourController.start(context: context, isDebug: true);
  /// });
  /// }
  /// ```
  Future<void> start({
    required BuildContext context,
    bool force = false,
  }) async {
    // Wait until the next frame of the application's UI has been drawn
    await Future.delayed(Duration.zero);

    if (_states.isEmpty) {
      printDebug('This value has no state');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    // Wait until the page transition animation is complete.
    if (context.mounted) {
      printDebug('Waiting for the page transition to complete..');
      final modalRoute = ModalRoute.of(context)?.animation;

      if (modalRoute == null ||
          modalRoute.isCompleted ||
          modalRoute.isDismissed) {
      } else {
        Completer completer = Completer();
        modalRoute.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) {
            if (!completer.isCompleted) completer.complete();
          }
        });
        await completer.future;
      }

      printDebug('Page transition completed.');
    }
    printDebug('Start the tour');

    // Sort the `_states` with its `index`
    if (_states.length > 1) _states.sort((a, b) => a.index.compareTo(b.index));

    while (_states.isNotEmpty) {
      // ignore: use_build_context_synchronously
      if (!context.mounted) break;

      final state = _states.elementAt(0);
      final key = FeaturesTour._getPrefKey(pageName, state);
      printDebug('Start widget with key $key');

      if (_prefs!.getBool(key) != true || force) {
        await state.showIntrodure();
      }

      await _removeState(state, !force);
    }

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
      final state = _states.elementAt(0);
      await _removeState(state, markAsShowed);
    }

    printDebug('Remove page: $pageName');
  }

  /// Removes all controllers for all pages
  Future<void> removeAll({bool markAsShowed = true}) =>
      FeaturesTour.removeAll(markAsShowed: markAsShowed);

  Future<void> _removeState(
    FeaturesTourStateMixin state,
    bool markAsShowed,
  ) async {
    if (markAsShowed) {
      // ignore: use_build_context_synchronously
      final key = FeaturesTour._getPrefKey(pageName, state);
      await _prefs!.setBool(key, true);
    }
    _unregister(state);
  }
}

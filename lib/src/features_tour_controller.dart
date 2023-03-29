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
  /// [context] will be used to wait for the page transition animation to complete.
  /// After that, delay for [delay] duration before starting the tour, it makes
  /// sure that all the widgets are rendered correctly, to enable all the tours,
  /// just need to set the [force] to true.
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
    Duration delay = Duration.zero,
    bool? force,
    PredialogConfig? predialogConfig,
  }) async {
    // Wait until the next frame of the application's UI has been drawn
    await null;

    final addBlank = ' $pageName ';
    printDebug(''.padLeft(50, '='));
    printDebug('${addBlank.padLeft(25 + (addBlank.length / 2).round(), '=')}'
        '${''.padRight(25 - (addBlank.length / 2).round(), '=')}');
    printDebug(''.padLeft(50, '='));

    if (_states.isEmpty) {
      printDebug('This page has no state');
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

    // Wait for `delay` duration before starting the tours.
    await Future.delayed(delay);

    if (_shouldShowPredialog()) {
      printDebug('Should show predialog return true');
      predialogConfig ??= PredialogConfig.global;

      if (predialogConfig.enabled) {
        printDebug('Predialog is enabled');

        // ignore: use_build_context_synchronously
        final predialogResult = await predialog(
          context,
          predialogConfig,
        );

        if (predialogResult != true) {
          printDebug('User is cancelled to show the introduction');
          return;
        }
      } else {
        printDebug('Predialog is not enabled');
      }
    } else {
      printDebug('Should show predialog return false');
    }

    // Sort the `_states` with its `index`
    if (_states.length > 1) _states.sort((a, b) => a.index.compareTo(b.index));

    // Get default value from global `force`
    force ??= FeaturesTour._force;

    printDebug('Start the tour');
    while (_states.isNotEmpty) {
      final state = _states.elementAt(0);
      final key = FeaturesTour._getPrefKey(pageName, state);
      printDebug('Start widget with key $key:');

      // ignore: use_build_context_synchronously
      if (!context.mounted) {
        printDebug('   -> This widget was unmounted');
        break;
      }

      if (_prefs!.getBool(key) == true) {
        printDebug('   -> This widget is already shown');

        // If not forcing to show this widget introduce, just continuing
        if (!force) {
          await _removeState(state, false);
          continue;
        }

        printDebug('   -> Force is true, continue to show this widget');
      }

      final result = await state.showIntroduce(state);

      switch (result) {
        case IntroduceResult.disabled:
        case IntroduceResult.notMounted:
        case IntroduceResult.wrongState:
          printDebug(
            '   -> This widget has been cancelled with result: ${result.name}',
          );
          await _removeState(state, false);
          break;
        case IntroduceResult.next:
          printDebug('   -> Move to next widget');
          await _removeState(state, true);
          break;
        case IntroduceResult.skip:
          printDebug('   -> Skip this tour');
          await _removePage(markAsShowed: true);
          break;
      }
    }

    printDebug('This tour has been completed');
  }

  /// Removes all controllers for specific `pageName`
  Future<void> _removePage({bool markAsShowed = true}) async {
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
  // Future<void> _removeAll({bool markAsShowed = true}) =>
  //     FeaturesTour.removeAll(markAsShowed: markAsShowed);

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

  bool _shouldShowPredialog() {
    for (final state in _states) {
      final key = FeaturesTour._getPrefKey(pageName, state);
      if (!_prefs!.containsKey(key)) {
        return true;
      }
    }

    return false;
  }
}

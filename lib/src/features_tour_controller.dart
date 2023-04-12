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

  /// Get auto increment index number
  double get _getAutoIndex => _index++;
  double _index = 0;

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
  /// just need to set the [force] to `true`.
  ///
  /// You can also configure the predialog by using [predialogConfig], this dialog
  /// will show to ask the user want to start the tour or not.
  ///
  /// Ex:
  /// ``` dart
  /// tourController.start(context: context, force: true);
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
      printDebug('The page $pageName has no state');
      return;
    }

    // ignore: use_build_context_synchronously
    if (!context.mounted) {
      printDebug('The page $pageName context is not mounted');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    // Wait until the page transition animation is complete.
    printDebug('Waiting for the page transition to complete..');

    // ignore: use_build_context_synchronously
    await _waitForTransition(context); // Main page transition

    printDebug('Page transition completed.');

    // Wait for `delay` duration before starting the tours.
    await Future.delayed(delay);

    // Get default value from global `force`
    force ??= FeaturesTour._force;

    bool shouldShowDialog = _shouldShowPredialog();
    if (!shouldShowDialog && force) {
      printDebug('Should show dialog is false but force is true.');
      shouldShowDialog = true;
    }
    if (shouldShowDialog) {
      printDebug('Should show predialog return true');
      predialogConfig ??= PredialogConfig.global;

      if (predialogConfig.enabled) {
        printDebug('Predialog is enabled');

        final bool? predialogResult;
        if (predialogConfig.modifiedDialogResult != null) {
          Completer<bool> completer = Completer();
          // ignore: use_build_context_synchronously
          completer.complete(predialogConfig.modifiedDialogResult!(context));
          predialogResult = await completer.future;
        } else {
          // ignore: use_build_context_synchronously
          predialogResult = await predialog(
            context,
            predialogConfig,
          );
        }

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

    // Watching for the `waitForIndex` value
    FeaturesTourStateMixin? waitForIndexState;

    printDebug('Start the tour');
    while (_states.isNotEmpty) {
      final FeaturesTourStateMixin state;

      if (waitForIndexState == null) {
        // Sort the `_states` with its' `index`
        // Place sort in this place will improve the sort behavior, specially when new states are added.
        _states.sort((a, b) => a.index.compareTo(b.index));
        state = _states.elementAt(0);
      } else {
        state = waitForIndexState;
      }

      final waitForIndex = state.waitForIndex;
      final waitForTimeout = state.waitForTimeout;
      final key = FeaturesTour._getPrefKey(pageName, state);
      printDebug('Start widget with key $key:');

      // ignore: use_build_context_synchronously
      if (!context.mounted || !state.currentContext.mounted) {
        printDebug('   -> This widget was unmounted');
        break;
      }

      // Wait for the child widget transition to complete
      await _waitForTransition(state.currentContext);

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

      // Wait for the next state to appear if `waitForIndex` is non-null
      if (waitForIndex != null) {
        printDebug(
            'The `waitForIndex` is non-null => Waiting for the next index: $waitForIndex ...');
        waitForIndexState = await _waitForIndex(waitForIndex, waitForTimeout);

        if (waitForIndexState == null) {
          printDebug(
              '   -> Cannot not wait for next index because timeout is reached. Use orderd values instead.');
        } else {
          printDebug('   -> Next index is available with state: $state');
        }
      } else {
        waitForIndexState = null;
      }
    }

    printDebug('This tour has been completed');
  }

  /// Wait for the next index to be available
  Future<FeaturesTourStateMixin?> _waitForIndex(
    double index,
    Duration timeout,
  ) async {
    Stopwatch stopwatch = Stopwatch()..start();
    while (true) {
      for (final state in _states) {
        if (state.index == index) return state;
      }

      // Timeout is reached.
      if (stopwatch.elapsed >= timeout) return null;

      // Delay for 100 milliseconds.
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Wait until the page transition animation is complete.
  Future<void> _waitForTransition(BuildContext context) async {
    if (!context.mounted) return;

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

  /// Removes specific state of this page
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

  /// Checks whether there is any new features available to show predialog
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

part of 'features_tour.dart';

class FeaturesTourController {
  /// Internal preferences.
  static SharedPreferences? _prefs;

  /// Store all available controllers
  static final Set<FeaturesTourController> _controllers = {};

  /// Creates a [FeaturesTourController] for the tour with a unique [pageName].
  /// The [pageName] is used to persist the state of the current page.
  ///
  /// **Note:** Avoid changing the [pageName] to prevent re-displaying the instructions
  /// for this page.
  FeaturesTourController(this.pageName) {
    _controllers.add(this);
  }

  /// Name of this page.
  final String pageName;

  /// The internal list of the states.
  final SplayTreeMap<double, FeaturesTour> _states =
      SplayTreeMap.from({}, (a, b) => a.compareTo(b));

  final _globalKeys = <double, GlobalKey>{};

  /// The internal list of the introduced states.
  final Set<double> _introducedIndexes = {};

  Completer? _introduceCompleter;

  bool _isIntroducing = false;

  /// Register the current FeaturesTour state.
  void _register(FeaturesTour state) {
    if (!_states.containsKey(state.index)) {
      printDebug(() =>
          '`$pageName`: register index ${state.index} => total: ${_states.length + 1}');
    }
    _states[state.index] = state;
    _globalKeys[state.index] = state._resolveKey();
  }

  /// Unregister the current FeaturesTour state.
  void _unregister(FeaturesTour state) {
    if (_states.containsKey(state.index)) {
      printDebug(() =>
          '`$pageName`: unregister index ${state.index} => total: ${_states.length - 1}');
    }
    _states.remove(state.index);
    _introducedIndexes.add(state.index);
  }

  /// Starts the tour. This package automatically saves the state of the tour,
  /// skipping widgets that have already been shown.
  ///
  /// All parameters provided will be applied to this controller (specific to this page)
  /// if set. Otherwise, the global configurations will be used.
  ///
  /// The [context] is required to wait for the page transition animation to complete.
  /// After the transition, a delay specified by [delay] ensures all widgets are
  /// rendered correctly before starting the tour. To enable or disable all tours,
  /// set [force] to `true` or `false`. This will also force all pre-dialogs to appear.
  /// **Important:** Reset [force] to `null` before releasing the app to ensure the
  /// [FeaturesTour] behaves as expected.
  ///
  /// Set the initial index for the tour using [waitForFirstIndex], with a timeout
  /// specified by [waitForFirstTimeout]. If the timeout is exceeded, the smallest
  /// available index will be used.
  ///
  /// The pre-dialog can be configured using [predialogConfig]. This dialog prompts
  /// the user to confirm whether they want to start the tour.
  ///
  /// Example:
  /// ```dart
  /// tourController.start(context: context, force: true);
  /// ```
  Future<void> start(
    BuildContext context, {
    double? waitForFirstIndex,
    Duration waitForFirstTimeout = const Duration(seconds: 3),
    Duration delay = const Duration(milliseconds: 500),
    bool? force,
    PredialogConfig? predialogConfig,
    bool? debugLog,
  }) async {
    if (_isIntroducing) {
      printDebug(() => 'The tour is already in progress');
      return;
    }
    _isIntroducing = true;

    // Wait until the next frame of the application's UI has been drawn.
    await null;

    bool cachedDebugLog = FeaturesTour._debugLog;
    if (debugLog != null) {
      FeaturesTour._debugLog = debugLog;
    }

    final addBlank = ' $pageName ';
    printDebug(() => ''.padLeft(50, '='));
    printDebug(
        () => '${addBlank.padLeft(25 + (addBlank.length / 2).round(), '=')}'
            '${''.padRight(25 - (addBlank.length / 2).round(), '=')}');
    printDebug(() => ''.padLeft(50, '='));

    void cleanup() {
      hideCover(context);
      FeaturesTour._debugLog = cachedDebugLog;
      _isIntroducing = false;
    }

    if (!context.mounted) {
      printDebug(() => 'The page $pageName context is not mounted');
      cleanup();
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    if (!context.mounted) {
      printDebug(() => 'The page $pageName context is not mounted');
      cleanup();
      return;
    }

    await _waitForTransition(context); // Main page transition

    // Wait for `delay` duration before starting the tours.
    await Future.delayed(delay);

    if (_states.isEmpty && waitForFirstIndex == null) {
      printDebug(() => 'The page $pageName has no state');
      cleanup();
      return;
    }

    // Get default value from global `force`.
    force ??= FeaturesTour._force;

    // Ignore all the tours
    if (force == null && await SharedPrefs.getDismissAllTours() == true) {
      printDebug(() => 'All tours have been dismissed');
      _removePage(markAsShowed: true);
      cleanup();
      return;
    }

    // All introduced states should be cleared before running a new tour to avoid
    // caching.
    _introducedIndexes.clear();

    if (!_shouldShowIntroduction() && force != true) {
      printDebug(() => 'There is no new `FeaturesTour` -> Completed');
      cleanup();
      return;
    }

    if (!context.mounted) {
      printDebug(() => 'The page $pageName context is not mounted');
      cleanup();
      return;
    }

    // Put this here so we don't have to check the context again.
    final defaultIntroduceBackgroundColor = _getOnSurfaceDefaultColor(context);

    final result = await _showPredialog(context, force, predialogConfig);

    switch (result) {
      case ButtonTypes.accept:
        break;
      case ButtonTypes.later:
        printDebug(() => 'User chose to show the introduction later');
        cleanup();
        return;
      case ButtonTypes.dismiss:
        printDebug(() => 'User dismissed to show the introduction');
        _removePage(markAsShowed: true);
        cleanup();
        return;
    }

    // Watching for the `waitForIndex` value.
    FeaturesTour? waitForIndexState;

    // Waiting for the first index.
    if (waitForFirstIndex != null) {
      waitForIndexState =
          await _waitForIndex(waitForFirstIndex, waitForFirstTimeout);
    }

    printDebug(() => 'Start the tour');
    while (_states.isNotEmpty) {
      await _removedAllShownIntroductions(force);
      if (_states.isEmpty) break;

      final FeaturesTour state;

      if (waitForIndexState == null) {
        state = _states.remove(_states.firstKey())!;
      } else {
        state = waitForIndexState;
        _states.remove(waitForIndexState.index);
      }

      final waitForIndex = state.waitForIndex;
      final waitForTimeout = state.waitForTimeout;
      final key = FeaturesTour._getPrefKey(pageName, state);
      printDebug(() => 'Start widget with key $key:');

      if (!context.mounted) {
        printDebug(() => '   -> The parent widget was unmounted');
        break;
      }

      bool shouldShowIntroduce;
      if (force != null) {
        printDebug(
            () => '`force` is $force, so the introduction must respect it.');
        shouldShowIntroduce = force;
      } else {
        printDebug(
            () => '`force` is null, so the introduce will act like normal.');
        final isShown = _prefs!.getBool(key);
        shouldShowIntroduce = isShown != true;
      }

      if (_introducedIndexes.contains(state.index)) {
        shouldShowIntroduce = false;
      }

      if (!shouldShowIntroduce) {
        printDebug(() =>
            '   -> This widget has been introduced -> move to the next widget.');
        await _removeState(state, false);
        continue;
      }

      // Wait for the child widget transition to complete.
      await _waitForTransition(state._context);

      if (!context.mounted) {
        printDebug(() => '   -> The parent widget was unmounted');
        break;
      }

      // Close the previous cover if it exists.
      hideCover(context);

      // Show the cover to avoid user tapping the screen.
      final introduceConfig = state.introduceConfig ?? IntroduceConfig.global;
      final introduceBackgroundColor =
          introduceConfig.backgroundColor ?? defaultIntroduceBackgroundColor;
      showCover(context, introduceBackgroundColor);

      await state.onBeforeIntroduce?.call();

      if (!context.mounted) {
        printDebug(() => '   -> The parent widget was unmounted');
        break;
      }

      // If there is no state in queue and no index to wait for then it's
      // the last state.
      final isLastState = _states.isEmpty && waitForIndex == null;
      final result = await _showIntroduce(context, state, isLastState);

      switch (result) {
        case IntroduceResult.disabled:
        case IntroduceResult.notMounted:
          await _removeState(state, false);
          break;
        case IntroduceResult.done:
        case IntroduceResult.next:
          await _removeState(state, true);
          // ignore: deprecated_member_use_from_same_package
          if (state.onPressed != null && state.onAfterIntroduce == null) {
            printDebug(() => '   -> Call `onPressed`');
            // ignore: deprecated_member_use_from_same_package
            await state.onPressed!();
          }
          break;
        case IntroduceResult.skip:
          await _removeState(state, true);
          await _removePage(markAsShowed: true);
          final skipConfig = state.skipConfig ?? SkipConfig.global;
          // ignore: deprecated_member_use_from_same_package
          if (skipConfig.isCallOnPressed &&
              // ignore: deprecated_member_use_from_same_package
              state.onPressed != null &&
              state.onAfterIntroduce == null) {
            printDebug(() => '   -> Call `onPressed`');
            // ignore: deprecated_member_use_from_same_package
            await state.onPressed!();
          }
          break;
      }

      if (state.onAfterIntroduce != null) {
        printDebug(() => '   -> Call `onAfterIntroduce`');
        await state.onAfterIntroduce!(result);
      }

      final status = switch (result) {
        IntroduceResult.disabled ||
        IntroduceResult.notMounted =>
          'This widget has been cancelled with result: ${result.name}',
        IntroduceResult.next => 'Move to the next widget',
        IntroduceResult.skip => 'Skip this tour',
        IntroduceResult.done => 'The Tour has been completed',
      };
      printDebug(() => '   -> $status');

      // Do not continue if the tour is ended.
      if (result != IntroduceResult.next) break;

      // Wait for the next state to appear if `waitForIndex` is non-null.
      if (waitForIndex != null) {
        printDebug(() =>
            'The `waitForIndex` is non-null => Waiting for the next index: $waitForIndex ...');

        waitForIndexState = await _waitForIndex(waitForIndex, waitForTimeout);

        if (waitForIndexState == null) {
          printDebug(() =>
              '   -> Cannot not wait for the next index $waitForIndex because timeout is reached. Use the next ordered value instead.');

          // Add the timeout state index to the introduced list so I will not
          // be introduced even when it's shown.
          _introducedIndexes.add(waitForIndex);
        } else {
          printDebug(() => '   -> Next index is available with state: $state');
        }
      } else {
        waitForIndexState = null;
      }
    }

    cleanup();
    printDebug(() => 'This tour has been completed');
  }

  /// Stops the current tour by sending a skip signal, equivalent to pressing
  /// the SKIP button.
  Future<void> _stop() async {
    if (_introduceCompleter != null && !_introduceCompleter!.isCompleted) {
      _introduceCompleter?.complete(IntroduceResult.skip);
    }
  }

  Future<IntroduceResult> _showIntroduce(
    BuildContext context,
    FeaturesTour state,
    bool isLastState,
  ) async {
    if (!context.mounted) {
      return IntroduceResult.notMounted;
    }

    if (!state.enabled || UnfeaturesTour.isUnfeaturesTour(context)) {
      return IntroduceResult.disabled;
    }

    final introduceConfig = state.introduceConfig ?? IntroduceConfig.global;
    final childConfig = state.childConfig ?? ChildConfig.global;
    final skipConfig = state.skipConfig ?? SkipConfig.global;
    final nextConfig = state.nextConfig ?? NextConfig.global;
    final doneConfig = state.doneConfig ?? DoneConfig.global;

    _introduceCompleter = Completer<IntroduceResult>();

    void complete(IntroduceResult result) {
      if (_introduceCompleter != null && !_introduceCompleter!.isCompleted) {
        _introduceCompleter?.complete(result);
      }
    }

    final overlayEntry = OverlayEntry(builder: (ctx) {
      return GestureDetector(
        onTap: childConfig.barrierDismissible
            ? () => complete(IntroduceResult.next)
            : null,
        child: Material(
          color: Colors.transparent,
          child: FeaturesChild(
            globalKey: state._resolveKey(),
            childConfig: childConfig,
            introduce: state.introduce,
            skip: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: skipConfig.child != null
                    ? skipConfig.child!(() {
                        complete(IntroduceResult.skip);
                      })
                    : ElevatedButton(
                        onPressed: () {
                          complete(IntroduceResult.skip);
                        },
                        style: skipConfig.buttonStyle,
                        child: Text(
                          skipConfig.text,
                          style: skipConfig.textStyle ??
                              TextStyle(color: skipConfig.color),
                        ),
                      ),
              ),
            ),
            skipConfig: skipConfig,
            next: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: nextConfig.child != null
                    ? nextConfig.child!(() {
                        complete(IntroduceResult.next);
                      })
                    : ElevatedButton(
                        onPressed: () {
                          complete(IntroduceResult.next);
                        },
                        style: nextConfig.buttonStyle,
                        child: Text(
                          nextConfig.text,
                          style: nextConfig.textStyle ??
                              TextStyle(color: nextConfig.color),
                        ),
                      ),
              ),
            ),
            doneConfig: doneConfig,
            done: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: doneConfig.child != null
                    ? doneConfig.child!(() {
                        complete(IntroduceResult.done);
                      })
                    : ElevatedButton(
                        onPressed: () {
                          complete(IntroduceResult.done);
                        },
                        style: doneConfig.buttonStyle,
                        child: Text(
                          doneConfig.text,
                          style: doneConfig.textStyle ??
                              TextStyle(color: doneConfig.color),
                        ),
                      ),
              ),
            ),
            isLastState: isLastState,
            nextConfig: nextConfig,
            padding: introduceConfig.padding,
            alignment: introduceConfig.alignment,
            quadrantAlignment: introduceConfig.quadrantAlignment,
            child: GestureDetector(
              onTap: () {
                complete(IntroduceResult.next);
              },
              child: Material(
                color: Colors.transparent,
                type: MaterialType.canvas,
                child: AbsorbPointer(
                  absorbing: true,
                  child: UnfeaturesTour(
                    child: childConfig.child?.call(state.child) ?? state.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });

    if (!context.mounted) return IntroduceResult.notMounted;

    Overlay.of(
      context,
      rootOverlay: introduceConfig.useRootOverlay,
    ).insert(overlayEntry);

    final result = await _introduceCompleter!.future;
    _introduceCompleter = null;

    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }

    return result;
  }

  Future<void> _removedAllShownIntroductions(bool? force) async {
    if (force == true) return;
    if (force == false) {
      _states.clear();
    }

    List<double> removedIndexes = [];
    for (final state in _states.entries) {
      final tour = state.value;
      if (_introducedIndexes.contains(state.key)) {
        removedIndexes.add(state.key);
      } else {
        final key = FeaturesTour._getPrefKey(pageName, tour);
        final isShown = _prefs!.getBool(key);
        if (isShown == true) {
          removedIndexes.add(state.key);
        }
      }
    }

    for (final key in removedIndexes) {
      _states.remove(key);
    }
  }

  /// Show the predialog if possible.
  Future<ButtonTypes> _showPredialog(
    BuildContext context,
    bool? force,
    PredialogConfig? config,
  ) async {
    // Should show the predialog or not.
    bool shouldShowPredialog = true;

    // Respect `force`.
    if (force != null) {
      printDebug(() => '`force` is $force, so the dialog must respect it.');
      shouldShowPredialog = force;
    }

    if (shouldShowPredialog) {
      printDebug(() => 'Should show predialog return true');
      config ??= PredialogConfig.global;

      if (config.enabled) {
        printDebug(() => 'Predialog is enabled');

        final ButtonTypes? predialogResult;
        if (config.modifiedDialogResult != null) {
          Completer<bool> completer = Completer();
          completer.complete(config.modifiedDialogResult!(context));
          predialogResult = switch (await completer.future) {
            true => ButtonTypes.accept,
            false => ButtonTypes.later,
          };
        } else {
          predialogResult = await predialog(
            context,
            config,
          );
        }

        switch (predialogResult) {
          case ButtonTypes.accept:
            printDebug(() => 'User accepted to show the introduction');
            config.onAcceptButtonPressed?.call();
          case ButtonTypes.later:
            printDebug(() => 'User chose to show the introduction later');
            config.onLaterButtonPressed?.call();
          case ButtonTypes.dismiss:
            printDebug(() => 'User dismissed to show the introduction');
            config.onDismissButtonPressed?.call();
        }

        return predialogResult;
      } else {
        printDebug(() => 'Predialog is not enabled');
      }
    } else {
      printDebug(() => 'Should show predialog return false');
    }

    return ButtonTypes.accept;
  }

  /// Wait for the next index to be available.
  Future<FeaturesTour?> _waitForIndex(
    double index,
    Duration timeout,
  ) async {
    Stopwatch stopwatch = Stopwatch()..start();
    while (true) {
      for (final MapEntry(key: i, value: state) in _states.entries) {
        if (i == index) return state;
      }

      // Timeout is reached.
      if (stopwatch.elapsed >= timeout) return null;

      // Delay for 100 milliseconds.
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Wait until the page transition animation is complete.
  Future<void> _waitForTransition(BuildContext? context) async {
    if (context == null || !context.mounted) return;

    printDebug(() => 'Waiting for the page transition to complete...');
    final modalRoute = ModalRoute.of(context)?.animation;

    if (modalRoute != null &&
        !modalRoute.isCompleted &&
        !modalRoute.isDismissed) {
      Completer completer = Completer();
      modalRoute.addStatusListener((status) {
        switch (status) {
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
          case AnimationStatus.dismissed:
          case AnimationStatus.completed:
            if (!completer.isCompleted) completer.complete();
        }
      });
      await completer.future;
    }

    // Wait for the drawer to close if it is open.
    if (context.mounted) {
      final drawer = DrawerController.maybeOf(context);
      if (drawer != null && drawer.isDrawerOpen) {
        // 246 milliseconds is the default duration for the drawer transition.
        await Future.delayed(const Duration(milliseconds: 246));
      }
    }
    printDebug(() => 'The page transition completed');
  }

  /// Removes all controllers for specific `pageName`.
  Future<void> _removePage({bool markAsShowed = true}) async {
    if (_states.isEmpty) {
      printDebug(() => 'Page $pageName has already been removed');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    while (_states.isNotEmpty) {
      final state = _states.values.first;
      await _removeState(state, markAsShowed);
    }

    printDebug(() => 'Remove page: $pageName');
  }

  /// Removes specific state of this page.
  Future<void> _removeState(
    FeaturesTour state,
    bool markAsIntroduced,
  ) async {
    if (markAsIntroduced) {
      final key = FeaturesTour._getPrefKey(pageName, state);
      await _prefs!.setBool(key, true);
    }
    _unregister(state);
  }

  /// Checks whether there is any new features available to show predialog.
  bool _shouldShowIntroduction() {
    for (final state in _states.values) {
      final key = FeaturesTour._getPrefKey(pageName, state);
      if (!_prefs!.containsKey(key) && (state._context?.mounted ?? false)) {
        return true;
      }
    }

    return false;
  }

  Color _getOnSurfaceDefaultColor(BuildContext context) {
    final onSurface = ColorScheme.of(context).onSurface;
    final brightness = Theme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      // TODO: Make this configurable.
      return onSurface.withValues(alpha: 0.74);
    }
    // TODO: Make this configurable.
    return onSurface.withValues(alpha: 0.82);
  }
}

part of 'features_tour.dart';

/// Creates a [FeaturesTourController] for the tour with a unique [pageName].
/// The [pageName] is used to persist the state of the current page.
///
/// **Note:** Avoid changing the [pageName] to prevent re-displaying the instructions
/// for this page.
class FeaturesTourController {
  /// Creates a [FeaturesTourController] for the tour with a unique [pageName].
  /// The [pageName] is used to persist the state of the current page.
  ///
  /// **Note:** Avoid changing the [pageName] to prevent re-displaying the instructions
  /// for this page.
  FeaturesTourController(this.pageName) {
    _controllers.add(this);
  }

  /// Internal preferences.
  static SharedPreferences? _prefs;

  /// Store all available controllers
  static final Set<FeaturesTourController> _controllers = {};

  /// Name of this page.
  final String pageName;

  /// The internal list of the states.
  final SplayTreeMap<double, _FeaturesTourState> _states =
      SplayTreeMap.from({}, (a, b) => a.compareTo(b));

  /// The internal cached states that have been unregistered.
  final _cachedStates = SplayTreeMap<double, _FeaturesTourState>.from(
      {}, (a, b) => a.compareTo(b));

  final _globalKeys = <double, GlobalKey>{};
  final Map<double, Completer<_FeaturesTourState>> _pendingIndexes = {};

  /// The internal list of the introduced states.
  final Set<double> _introducedIndexes = {};

  Completer<IntroduceResult>? _introduceCompleter;

  bool _isIntroducing = false;
  bool _debugLog = FeaturesTour._debugLog;

  /// Register the current FeaturesTour state.
  void _register(_FeaturesTourState state) {
    if (_debugLog && !_cachedStates.containsKey(state.widget.index)) {
      _printDebug(() =>
          '`$pageName`: register index ${state.widget.index} => total: ${_cachedStates.length + 1}');
    }
    _states[state.widget.index] = state;
    _cachedStates[state.widget.index] = state;
    _globalKeys[state.widget.index] ??=
        GlobalObjectKey('$pageName-${state.widget.index}');

    // Complete any pending completers for this index
    if (_pendingIndexes.containsKey(state.widget.index)) {
      _pendingIndexes[state.widget.index]!.complete(state);
      _pendingIndexes.remove(state.widget.index);
    }
  }

  /// Unregister the current FeaturesTour state.
  void _unregister(_FeaturesTourState state) {
    if (_debugLog && _cachedStates.containsKey(state.widget.index)) {
      _printDebug(() =>
          '`$pageName`: unregister index ${state.widget.index} => total: ${_cachedStates.length - 1}');
    }
    _states.remove(state.widget.index);
    _cachedStates.remove(state.widget.index);
    _introducedIndexes.add(state.widget.index);
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
  /// Set the initial index for the tour using [firstIndex], with a timeout
  /// specified by [firstIndexTimeout]. If the timeout is exceeded, the smallest
  /// available index will be used.
  ///
  /// The pre-dialog can be configured using [predialogConfig]. This dialog prompts
  /// the user to confirm whether they want to start the tour.
  ///
  /// The [onState] callback is an optional callback function that gets invoked
  /// with the current [TourState] of the tour. This allows you to monitor the tour's
  /// progress and respond to different states as they occur.
  ///
  /// Example:
  /// ```dart
  /// tourController.start(context: context, force: true);
  /// ```
  Future<void> start(
    BuildContext context, {
    @Deprecated(
      'Use `firstIndex` instead. This will be removed in the next release candidate.',
    )
    double? waitForFirstIndex,
    @Deprecated(
      'Use `firstIndexTimeout` instead. This will be removed in the next release candidate.',
    )
    Duration waitForFirstTimeout = const Duration(seconds: 3),
    double? firstIndex,
    // TODO(lamnhan066): Set `firstIndexTimeout` to `Duration(seconds: 3)` in the next release candidate.
    Duration? firstIndexTimeout,
    Duration delay = const Duration(milliseconds: 500),
    bool? force,
    PredialogConfig? predialogConfig,
    bool? debugLog,
    FutureOr<void> Function(TourState state)? onState,
  }) async {
    _debugLog = debugLog ?? FeaturesTour._debugLog;
    firstIndex ??= waitForFirstIndex;
    firstIndexTimeout ??= waitForFirstTimeout;

    if (_isIntroducing) {
      _printDebug(() => 'The tour is already in progress');
      await onState?.call(const TourInProgress());
      return;
    }
    _isIntroducing = true;

    // Wait until the next frame of the application's UI has been drawn.
    await null;

    final addBlank = ' $pageName ';
    _printDebug(() => ''.padLeft(50, '='));
    _printDebug(
        () => '${addBlank.padLeft(25 + (addBlank.length / 2).round(), '=')}'
            '${''.padRight(25 - (addBlank.length / 2).round(), '=')}');
    _printDebug(() => ''.padLeft(50, '='));

    try {
      if (!context.mounted) {
        _printDebug(() => 'The page $pageName context is not mounted');

        await onState?.call(const TourNotMounted());
        return;
      }

      _prefs ??= await SharedPreferences.getInstance();

      if (!context.mounted) {
        _printDebug(() => 'The page $pageName context is not mounted');

        await onState?.call(const TourNotMounted());
        return;
      }

      await _waitForTransition(context); // Main page transition

      // Wait for `delay` duration before starting the tours.
      await Future<void>.delayed(delay);

      // Get default value from global `force`.
      force ??= FeaturesTour._force;

      if (force ?? false) {
        _states
          ..clear()
          ..addAll(_cachedStates);
      }

      if (_states.isEmpty && firstIndex == null) {
        _printDebug(() => 'The page $pageName has no state');
        await onState?.call(const TourEmptyStates());
        return;
      }

      // Ignore all the tours
      if (force == null && await SharedPrefs.getDismissAllTours()) {
        _printDebug(() => 'All tours have been dismissed');
        await _removePage();
        await onState?.call(const TourAllTourDismissedByUser());
        return;
      }

      // All introduced states should be cleared before running a new tour to avoid
      // caching.
      _introducedIndexes.clear();

      if (!_shouldShowIntroduction() && force != true) {
        _printDebug(() => 'There is no new `FeaturesTour` -> Completed');
        await onState?.call(const TourEmptyStates());
        return;
      }

      if (!context.mounted) {
        _printDebug(() => 'The page $pageName context is not mounted');
        await onState?.call(const TourNotMounted());
        return;
      }

      // Put this here so we don't have to check the context again.
      final defaultIntroduceBackgroundColor =
          _getOnSurfaceDefaultColor(context);

      final result = await _showPredialog(
        context,
        force,
        predialogConfig,
        () async {
          _printDebug(() => 'Pre-dialog is shown');
          await onState?.call(const TourPreDialogIsShown());
        },
        (type) async {
          _printDebug(() => 'Applied to all pages');
          await onState?.call(TourPreDialogNowShownByAppliedToAllPages(type));
        },
      );

      switch (result) {
        case null:
          await onState?.call(const TourPreDialogNotShown());
        case PredialogButtonType.accept:
          await onState?.call(
            const TourPreDialogButtonPressed(PredialogButtonType.accept),
          );
        case PredialogButtonType.later:
          await onState?.call(
            const TourPreDialogButtonPressed(PredialogButtonType.later),
          );
          return;
        case PredialogButtonType.dismiss:
          await _removePage();
          await onState?.call(
            const TourPreDialogButtonPressed(PredialogButtonType.dismiss),
          );
          return;
      }

      // Watching for the [FeaturesTour.nextIndex] value.
      _FeaturesTourState? nextState;

      // Waiting for the first index.
      if (firstIndex != null) {
        nextState = await _nextIndex(firstIndex, firstIndexTimeout);
      }

      _printDebug(() => 'Start the tour');
      while (_states.isNotEmpty) {
        await _removedAllShownIntroductions(force);
        if (_states.isEmpty) {
          _printDebug(() => 'No more states to introduce');
          await onState?.call(const TourEmptyStates());
          break;
        }

        final _FeaturesTourState state;

        if (nextState == null) {
          state = _states.remove(_states.firstKey())!;
        } else {
          state = nextState;
          _states.remove(nextState.widget.index);
        }

        final nextIndex = state.widget.nextIndex;
        final nextIndexTimeout = state.widget.nextIndexTimeout;
        final key = _getPrefKey(state);
        _printDebug(() => 'Start widget with key $key:');

        if (!context.mounted) {
          _printDebug(() => '   -> The parent widget was unmounted');
          await onState?.call(const TourNotMounted());
          break;
        }

        bool shouldShowIntroduce;
        if (force != null) {
          _printDebug(
              () => '`force` is $force, so the introduction must respect it.');
          shouldShowIntroduce = force;
        } else {
          _printDebug(
              () => '`force` is null, so the introduce will act like normal.');
          final isShown = _prefs!.getBool(key);
          shouldShowIntroduce = isShown != true;
        }

        if (_introducedIndexes.contains(state.widget.index)) {
          shouldShowIntroduce = false;
        }

        if (!shouldShowIntroduce) {
          _printDebug(() =>
              '   -> This widget has been introduced -> move to the next widget.');
          await _removeState(state, false);
          await onState
              ?.call(TourShouldNotShowIntroduction(index: state.widget.index));
          continue;
        }

        // Wait for the child widget transition to complete.
        await _waitForTransition(context);

        if (!context.mounted) {
          _printDebug(() => '   -> The parent widget was unmounted');
          await onState?.call(const TourNotMounted());
          break;
        }

        // Close the previous cover if it exists.
        hideCover(_debugLog ? (log) => _printDebug(() => log) : null);

        // Show the cover to avoid user tapping the screen.
        final introduceConfig =
            state.widget.introduceConfig ?? IntroduceConfig.global;
        final introduceBackgroundColor =
            introduceConfig.backgroundColor ?? defaultIntroduceBackgroundColor;
        showCover(
          context,
          introduceBackgroundColor,
          _debugLog ? (log) => _printDebug(() => log) : null,
        );

        if (state.widget.onBeforeIntroduce != null) {
          _printDebug(() => '   -> Call `onBeforeIntroduce`');
          await state.widget.onBeforeIntroduce!();
          await onState?.call(const TourBeforeIntroduceCalled());
        }

        if (!context.mounted) {
          _printDebug(() => '   -> The parent widget was unmounted');
          await onState?.call(const TourNotMounted());
          break;
        }

        // If there is no state in queue and no index to wait for then it's
        // the last state.
        final isLastState = _states.isEmpty && nextIndex == null;
        final result =
            await _showIntroduce(context, state, isLastState, () async {
          _printDebug(() => '   -> Introduction is shown');
          await onState?.call(TourIntroducing(index: state.widget.index));
        });

        if (state.widget.onAfterIntroduce != null) {
          _printDebug(() => '   -> Call `onAfterIntroduce`');
          await state.widget.onAfterIntroduce!(result);
          await onState?.call(const TourAfterIntroduceCalled());
        }

        switch (result) {
          case IntroduceResult.disabled:
          case IntroduceResult.notMounted:
            await _removeState(state, false);
          case IntroduceResult.done:
          case IntroduceResult.next:
            await _removeState(state, true);
          case IntroduceResult.skip:
            await _removeState(state, true);
            await _removePage();
        }

        await onState?.call(TourIntroduceResultEmitted(result: result));

        String status() {
          return switch (result) {
            IntroduceResult.disabled ||
            IntroduceResult.notMounted =>
              'This widget has been cancelled with result: ${result.name}',
            IntroduceResult.next => 'Move to the next widget',
            IntroduceResult.skip => 'Skip this tour',
            IntroduceResult.done => 'The Tour has been completed',
          };
        }

        _printDebug(() => '   -> ${status()}');

        // Do not continue if the tour is ended.
        if (result != IntroduceResult.next) break;

        // Wait for the next state to appear if `nextIndex` is non-null.
        if (nextIndex != null) {
          _printDebug(() =>
              'The `nextIndex` is non-null => Waiting for the next index: $nextIndex ...');

          nextState = await _nextIndex(nextIndex, nextIndexTimeout);

          if (nextState == null) {
            _printDebug(() =>
                '   -> Cannot not wait for the next index $nextIndex because timeout is reached. Use the next ordered value instead.');

            // Add the timeout state index to the introduced list so I will not
            // be introduced even when it's shown.
            _introducedIndexes.add(nextIndex);
          } else {
            _printDebug(
                () => '   -> Next index is available with state: $nextState');
          }
        } else {
          nextState = null;
        }
      }
    } finally {
      hideCover(_debugLog ? (log) => _printDebug(() => log) : null);
      _debugLog = FeaturesTour._debugLog;
      await onState?.call(const TourCompleted());
      _printDebug(() => 'This tour has been completed');
      _isIntroducing = false;
    }
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
    _FeaturesTourState state,
    bool isLastState,
    FutureOr<void> Function() onShownIntroduction,
  ) async {
    if (!context.mounted) {
      return IntroduceResult.notMounted;
    }

    if (!state.widget.enabled || UnfeaturesTour.isUnfeaturesTour(context)) {
      return IntroduceResult.disabled;
    }

    final introduceConfig =
        state.widget.introduceConfig ?? IntroduceConfig.global;
    final childConfig = state.widget.childConfig ?? ChildConfig.global;
    final skipConfig = state.widget.skipConfig ?? SkipConfig.global;
    final nextConfig = state.widget.nextConfig ?? NextConfig.global;
    final doneConfig = state.widget.doneConfig ?? DoneConfig.global;

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
            globalKey: _globalKeys[state.widget.index]!,
            childConfig: childConfig,
            introduce: state.widget.introduce,
            skip: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.all(12),
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
                padding: const EdgeInsets.all(12),
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
                child: AbsorbPointer(
                  child: UnfeaturesTour(
                    child: childConfig.child?.call(state.widget.child) ??
                        state.widget.child,
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

    await onShownIntroduction();

    final result = await _introduceCompleter!.future;
    _introduceCompleter = null;

    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }

    return result;
  }

  Future<void> _removedAllShownIntroductions(bool? force) async {
    if (force ?? false) return;
    if (force == false) {
      _states.clear();
    }

    final removedIndexes = <double>[];
    for (final state in _states.entries) {
      final tour = state.value;
      if (_introducedIndexes.contains(state.key)) {
        removedIndexes.add(state.key);
      } else {
        final key = _getPrefKey(tour);
        final isShown = _prefs!.getBool(key);
        if (isShown ?? false) {
          removedIndexes.add(state.key);
        }
      }
    }

    for (final key in removedIndexes) {
      _states.remove(key);
    }
  }

  /// Show the predialog if possible.
  Future<PredialogButtonType?> _showPredialog(
    BuildContext context,
    bool? force,
    PredialogConfig? config,
    FutureOr<void> Function() onShownPreDialog,
    FutureOr<void> Function(PredialogButtonType type) onAppliedToAllPages,
  ) async {
    // Should show the predialog or not.
    var shouldShowPredialog = true;

    // Respect `force`.
    if (force != null) {
      _printDebug(() => '`force` is $force, so the dialog must respect it.');
      shouldShowPredialog = force;
    }

    if (shouldShowPredialog) {
      _printDebug(() => 'Should show predialog return true');
      final effectiveConfig = config ?? PredialogConfig.global;

      if (effectiveConfig.enabled) {
        _printDebug(() => 'Predialog is enabled');

        final PredialogButtonType? predialogResult;
        if (effectiveConfig.modifiedDialogResult != null) {
          final completer = Completer<bool>()
            ..complete(effectiveConfig.modifiedDialogResult!(context));
          predialogResult = switch (await completer.future) {
            true => PredialogButtonType.accept,
            false => PredialogButtonType.later,
          };
        } else {
          predialogResult = await predialog(
            context,
            effectiveConfig,
            onShownPreDialog,
            onAppliedToAllPages,
            _debugLog ? (log) => _printDebug(() => log) : null,
          );
        }

        switch (predialogResult) {
          case PredialogButtonType.accept:
            _printDebug(() => 'User accepted to show the introduction');
            effectiveConfig.onAcceptButtonPressed?.call();
          case PredialogButtonType.later:
            _printDebug(() => 'User chose to show the introduction later');
            effectiveConfig.onLaterButtonPressed?.call();
          case PredialogButtonType.dismiss:
            _printDebug(() => 'User dismissed to show the introduction');
            effectiveConfig.onDismissButtonPressed?.call();
        }

        return predialogResult;
      } else {
        _printDebug(() => 'Predialog is not enabled');
      }
    } else {
      _printDebug(() => 'Should show predialog return false');
    }

    return null;
  }

  /// Wait for the next index to be available.
  Future<_FeaturesTourState?> _nextIndex(
    double index,
    Duration timeout,
  ) async {
    // Check if the state is already available
    if (_states.containsKey(index)) {
      return _states[index];
    }

    // Create a completer if not already pending
    _pendingIndexes.putIfAbsent(index, Completer<_FeaturesTourState>.new);

    try {
      return await _pendingIndexes[index]!.future.timeout(timeout);
    } on TimeoutException {
      _printDebug(() => 'Timeout waiting for index $index');
      _pendingIndexes.remove(index); // Clean up the completer
      return null;
    }
  }

  /// Wait until the page transition (and optional drawer animation) is complete.
  Future<void> _waitForTransition(BuildContext? context) async {
    if (context == null || !context.mounted) return;

    _printDebug(() => '⏳ Waiting for the page transition...');

    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation != null &&
        !routeAnimation.isCompleted &&
        !routeAnimation.isDismissed) {
      final completer = Completer<void>();

      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          routeAnimation.removeStatusListener(listener);
          if (!completer.isCompleted) completer.complete();
        }
      }

      routeAnimation.addStatusListener(listener);
      await completer.future;
    }

    _printDebug(() => '✅ Page transition completed');
  }

  /// Removes all controllers for specific `pageName`.
  Future<void> _removePage({bool markAsShowed = true}) async {
    if (_states.isEmpty) {
      _printDebug(() => 'Page $pageName has already been removed');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    while (_states.isNotEmpty) {
      final state = _states.values.first;
      await _removeState(state, markAsShowed);
    }

    _printDebug(() => 'Remove page: $pageName');
  }

  /// Removes specific state of this page.
  Future<void> _removeState(
    _FeaturesTourState state,
    bool markAsIntroduced,
  ) async {
    if (markAsIntroduced) {
      final key = _getPrefKey(state);
      await _prefs!.setBool(key, true);
    }
    _states.remove(state.widget.index);
    _introducedIndexes.add(state.widget.index);
  }

  /// Checks whether there is any new features available to show predialog.
  bool _shouldShowIntroduction() {
    for (final state in _states.values) {
      final key = _getPrefKey(state);
      if (!_prefs!.containsKey(key) && state.context.mounted) {
        return true;
      }
    }

    return false;
  }

  Color _getOnSurfaceDefaultColor(BuildContext context) {
    return ColorScheme.of(context).onSurface.withValues(alpha: 0.82);
  }

  /// Get key for shared preferences.
  String _getPrefKey(_FeaturesTourState state) {
    return '${FeaturesTour._prefix}_${pageName}_${state.widget.index}';
  }

  /// Print debug message if debug is enabled.
  void _printDebug(String Function() message) {
    if (_debugLog) {
      debugPrint(message());
    }
  }
}

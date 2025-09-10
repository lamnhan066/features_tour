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

  /// The internal preferences.
  static SharedPreferences? _prefs;

  /// Stores all available controllers.
  static final Set<FeaturesTourController> _controllers = {};

  /// The name of this page.
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
  bool _popToSkip = true;
  Logger? _logger = FeaturesTour._globalLogger;

  /// Registers the current FeaturesTour state.
  void _register(_FeaturesTourState state) {
    if (_debugLog && !_cachedStates.containsKey(state.widget.index)) {
      _logger?.log(() =>
          'Registering index ${state.widget.index}. Total states: ${_cachedStates.length + 1}');
    }
    _states[state.widget.index] = state;
    _cachedStates[state.widget.index] = state;
    _globalKeys[state.widget.index] ??=
        GlobalObjectKey('$pageName-${state.widget.index}');

    // Completes any pending completers for this index.
    if (_pendingIndexes.containsKey(state.widget.index)) {
      _pendingIndexes[state.widget.index]!.complete(state);
      _pendingIndexes.remove(state.widget.index);
    }
  }

  /// Unregisters the current FeaturesTour state.
  void _unregister(_FeaturesTourState state) {
    if (_debugLog && _cachedStates.containsKey(state.widget.index)) {
      _logger?.log(() =>
          'Unregistering index ${state.widget.index}. Total states: ${_cachedStates.length - 1}');
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
  /// The [onState] callback is an optional callback function that is invoked
  /// with the current [TourState] of the tour. This allows you to monitor the tour's
  /// progress and respond to different states as they occur.
  ///
  /// If [popToSkip] is `true`, the user can skip the current tour by pressing
  /// the back button (Android) or swipe back gesture (iOS). If `false`, the
  /// back button or swipe back gesture will be disabled during the tour.
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
    @Deprecated(
      'Use `preDialogConfig` instead. This will be removed in the next major version.',
    )
    PreDialogConfig? predialogConfig,
    PreDialogConfig? preDialogConfig,
    FutureOr<void> Function(TourState state)? onState,
    bool popToSkip = true,
    bool? debugLog,
  }) async {
    assert(
      preDialogConfig == null || predialogConfig == null,
      'You can only set `predialogConfig` or `preDialogConfig`.',
    );
    final effectivePreDialogConfig = predialogConfig ?? preDialogConfig;
    _popToSkip = popToSkip;
    _debugLog = debugLog ?? FeaturesTour._debugLog;
    if (_debugLog) {
      _logger ??= Logger((s) => debugPrint('[FeaturesTour][$pageName]: $s'));
    } else {
      _logger = null;
    }
    firstIndex ??= waitForFirstIndex;
    firstIndexTimeout ??= waitForFirstTimeout;

    if (_isIntroducing) {
      _logger?.log(() => 'The tour is already in progress.');
      await onState?.call(const TourInProgress());
      return;
    }
    _isIntroducing = true;

    // Wait until the next frame of the application's UI has been drawn.
    await null;

    try {
      if (!context.mounted) {
        _logger?.log(() => 'The page $pageName context is not mounted.');

        await onState?.call(const TourNotMounted());
        return;
      }

      _prefs ??= await SharedPreferences.getInstance();

      if (!context.mounted) {
        _logger?.log(() => 'The page $pageName context is not mounted.');

        await onState?.call(const TourNotMounted());
        return;
      }

      _logger?.log(() => 'Waiting for the page transition...');
      await _waitForTransition(context); // Main page transition
      _logger?.log(() => 'Page transition completed.');

      // Wait for `delay` duration before starting the tours.
      await Future<void>.delayed(delay);

      // Gets the default value from the global `force`.
      force ??= FeaturesTour._force;

      if (force ?? false) {
        _states
          ..clear()
          ..addAll(_cachedStates);
      }

      if (_states.isEmpty && firstIndex == null) {
        _logger?.log(() => 'The page $pageName has no state.');
        await onState?.call(const TourEmpty());
        return;
      }

      // Ignore all the tours
      if (force == null && await DismissAllTourStorage.getDismissAllTours()) {
        _logger?.log(() => 'All tours have been dismissed.');
        await _removePage();
        await onState?.call(const TourDismissedAllByUser());
        return;
      }

      // All introduced states should be cleared before running a new tour to avoid
      // caching.
      _introducedIndexes.clear();

      if (!_shouldShowIntroduction() && force != true) {
        _logger?.log(() => 'There are no new `FeaturesTour`s. Tour completed.');
        await onState?.call(const TourEmpty());
        return;
      }

      if (!context.mounted) {
        _logger?.log(() => 'The page $pageName context is not mounted.');
        await onState?.call(const TourNotMounted());
        return;
      }

      final result = await _showPredialog(
        context,
        force,
        effectivePreDialogConfig,
        (isCustom) async {
          if (isCustom) {
            _logger?.log(() => 'A custom dialog is shown for the pre-dialog.');
            await onState?.call(const TourPreDialogShownCustom());
          } else {
            _logger?.log(() => 'The pre-dialog is shown.');
            await onState?.call(const TourPreDialogShownDefault());
          }
        },
        (type) async {
          _logger?.log(() => 'This has been applied to all pages.');
          await onState?.call(TourPreDialogHiddenByAppliedToAll(type));
        },
        (value) {
          _logger
              ?.log(() => 'The "Apply to all pages" checkbox is now $value.');
          onState?.call(TourPreDialogApplyToAllChanged(value));
        },
      );

      switch (result) {
        case null:
          await onState?.call(const TourPreDialogHidden());
        case PreDialogButtonType.accept:
          _logger?.log(() => 'The user accepted to show the introduction.');
          await onState?.call(
            const TourPreDialogButtonPressed(PreDialogButtonType.accept),
          );
        case PreDialogButtonType.later:
          _logger?.log(() => 'The user chose to show the introduction later.');
          await onState?.call(
            const TourPreDialogButtonPressed(PreDialogButtonType.later),
          );
          return;
        case PreDialogButtonType.dismiss:
          _logger?.log(() => 'The user dismissed the introduction.');
          await _removePage();
          await onState?.call(
            const TourPreDialogButtonPressed(PreDialogButtonType.dismiss),
          );
          return;
      }

      // Watches for the [FeaturesTour.nextIndex] value.
      _FeaturesTourState? nextState;

      // Waits for the first index.
      if (firstIndex != null) {
        nextState = await _nextIndex(firstIndex, firstIndexTimeout);
      }

      _logger?.log(() => 'Starting the tour.');
      while (_states.isNotEmpty) {
        await _removedAllShownIntroductions(force);
        if (_states.isEmpty) {
          _logger?.log(() => 'No more states to introduce.');
          await onState?.call(const TourEmpty());
          break;
        }

        final _FeaturesTourState state;

        if (nextState == null) {
          state = _states.remove(_states.firstKey())!;
        } else {
          state = nextState;
          _states.remove(nextState.widget.index);
        }

        state._blockPop();

        final nextIndex = state.widget.nextIndex;
        final nextIndexTimeout = state.widget.nextIndexTimeout;
        final key = _getPrefKey(state);
        _logger?.log(() => 'Start introducing $key:');

        if (!context.mounted) {
          _logger?.log(() => '   -> The parent widget was unmounted.');
          await onState?.call(const TourNotMounted());
          break;
        }

        bool shouldShowIntroduce;
        if (force != null) {
          _logger?.log(() =>
              '   -> `force` is $force, so the introduction must respect it.');
          shouldShowIntroduce = force;
        } else {
          _logger?.log(() =>
              '   -> `force` is null, so the introduction will act like normal.');
          final isShown = _prefs!.getBool(key);
          shouldShowIntroduce = isShown != true;
        }

        if (_introducedIndexes.contains(state.widget.index)) {
          shouldShowIntroduce = false;
        }

        if (!shouldShowIntroduce) {
          _logger?.log(() =>
              '   -> This widget has been introduced. Moving to the next widget.');
          await _removeState(state, false);
          await onState
              ?.call(TourSkippedIntroduction(index: state.widget.index));
          continue;
        }

        _logger?.log(() => '   -> Waiting for the page transition...');
        await _waitForTransition(context); // Main page transition
        _logger?.log(() => '   -> Page transition completed.');

        if (!context.mounted) {
          _logger?.log(() => '   -> The parent widget was unmounted');
          await onState?.call(const TourNotMounted());
          break;
        }

        // Closes the previous cover if it exists.
        hideCover(_debugLog ? (log) => _logger?.log(() => '   -> $log') : null);

        // Shows the cover to prevent the user from tapping the screen.
        final introduceConfig =
            state.widget.introduceConfig ?? IntroduceConfig.global;
        final introduceBackgroundColor =
            introduceConfig.barrierColorBuilder(context);

        showCover(
          context,
          introduceBackgroundColor,
          _debugLog ? (log) => _logger?.log(() => '   -> $log') : null,
        );

        if (state.widget.onBeforeIntroduce != null) {
          _logger?.log(() => '   -> Calling `onBeforeIntroduce`.');
          await state.widget.onBeforeIntroduce!();
          await onState?.call(const TourBeforeIntroduceCalled());
        }

        if (!context.mounted) {
          _logger?.log(() => '   -> The parent widget was unmounted.');
          await onState?.call(const TourNotMounted());
          break;
        }

        // If there is no state in the queue and no index to wait for, then it's
        // the last state.
        final isLastState = _states.isEmpty && nextIndex == null;
        final result = await _showIntroduce(
          context,
          state,
          isLastState,
          () async {
            _logger?.log(() => '   -> The introduction is shown.');
            await onState?.call(TourIntroducing(index: state.widget.index));
          },
        );

        if (state.widget.onAfterIntroduce != null) {
          _logger?.log(() => '   -> Calling `onAfterIntroduce`.');
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
              'This widget has been canceled with result: ${result.name}.',
            IntroduceResult.next => 'Moving to the next widget.',
            IntroduceResult.skip => 'Skipping this tour.',
            IntroduceResult.done => 'The tour has been completed.',
          };
        }

        _logger?.log(() => '   -> ${status()}');

        // Does not continue if the tour has ended.
        if (result != IntroduceResult.next) break;

        // Waits for the next state to appear if `nextIndex` is non-null.
        if (nextIndex != null) {
          _logger?.log(() =>
              'The `nextIndex` is non-null. Waiting for the next index: $nextIndex...');

          nextState = await _nextIndex(nextIndex, nextIndexTimeout);

          if (nextState == null) {
            _logger?.log(() =>
                'Cannot wait for the next index $nextIndex because the timeout was reached. Using the next ordered value instead.');

            // Adds the timeout state index to the introduced list so it will not
            // be introduced even when it's shown.
            _introducedIndexes.add(nextIndex);
          } else {
            _logger?.log(
                () => 'The next index is available with state: $nextState.');
          }
        } else {
          nextState = null;
        }
      }
    } finally {
      for (final state in _cachedStates.values) {
        state._allowPop();
      }
      hideCover(_debugLog ? (log) => _logger?.log(() => log) : null);
      _debugLog = FeaturesTour._debugLog;
      await onState?.call(const TourCompleted());
      _logger?.log(() => 'This tour has been completed.');
      _isIntroducing = false;
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

    void skipAction() => complete(IntroduceResult.skip);
    // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
    // ignore: deprecated_member_use_from_same_package
    final skipButton = skipConfig.child?.call(skipAction) ??
        skipConfig.builder?.call(context, skipAction) ??
        ElevatedButton(
          onPressed: skipAction,
          style: skipConfig.buttonStyle,
          child: Text(
            skipConfig.text,
            style: skipConfig.textStyle ?? TextStyle(color: skipConfig.color),
          ),
        );

    void nextAction() => complete(IntroduceResult.next);
    // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
    // ignore: deprecated_member_use_from_same_package
    final nextButton = nextConfig.child?.call(nextAction) ??
        nextConfig.builder?.call(context, nextAction) ??
        ElevatedButton(
          onPressed: nextAction,
          style: nextConfig.buttonStyle,
          child: Text(
            nextConfig.text,
            style: nextConfig.textStyle ?? TextStyle(color: nextConfig.color),
          ),
        );

    void doneAction() => complete(IntroduceResult.done);
    // TODO(lamnhan066): Remove deprecated `child` in the next stable release.
    // ignore: deprecated_member_use_from_same_package
    final doneButton = doneConfig.child?.call(doneAction) ??
        doneConfig.builder?.call(context, doneAction) ??
        ElevatedButton(
          onPressed: doneAction,
          style: doneConfig.buttonStyle,
          child: Text(
            doneConfig.text,
            style: doneConfig.textStyle ?? TextStyle(color: doneConfig.color),
          ),
        );

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
            introduceConfig: introduceConfig,
            skip: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: skipButton,
              ),
            ),
            skipConfig: skipConfig,
            next: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: nextButton,
              ),
            ),
            doneConfig: doneConfig,
            done: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: doneButton,
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

  void _handlePopScope() {
    if (!_popToSkip) {
      _logger?.log(() => 'Pop to skip is disabled.');
      return;
    }

    if (_introduceCompleter == null || _introduceCompleter!.isCompleted) {
      return;
    }

    _introduceCompleter?.complete(IntroduceResult.skip);
    _logger?.log(() => 'Pop to skip is enabled. Skipping the tour.');
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

  /// Shows the pre-dialog if possible.
  Future<PreDialogButtonType?> _showPredialog(
    BuildContext context,
    bool? force,
    PreDialogConfig? config,
    FutureOr<void> Function(bool isCustom) onPreDialogIsDisplayed,
    FutureOr<void> Function(PreDialogButtonType type) onAppliedToAllPages,
    void Function(bool value) onApplyToAllPagesCheckboxChanged,
  ) async {
    // Determines whether to show the pre-dialog.
    var shouldShowPredialog = true;

    // Respects `force`.
    if (force != null) {
      _logger?.log(() => '`force` is $force, so the dialog must respect it.');
      shouldShowPredialog = force;
    }

    if (shouldShowPredialog) {
      _logger?.log(() => 'Should show pre-dialog returned true.');
      final effectiveConfig = config ?? PreDialogConfig.global;

      if (effectiveConfig.enabled) {
        _logger?.log(() => 'The pre-dialog is enabled.');

        final predialogResult = await showPreDialog(
          context,
          effectiveConfig,
          onPreDialogIsDisplayed,
          onAppliedToAllPages,
          onApplyToAllPagesCheckboxChanged,
          _debugLog ? (log) => _logger?.log(() => log) : null,
        );

        return predialogResult;
      } else {
        _logger?.log(() => 'The pre-dialog is not enabled.');
      }
      return null;
    } else {
      _logger?.log(() => 'Should show pre-dialog returned false.');
    }

    return null;
  }

  /// Waits for the next index to be available.
  Future<_FeaturesTourState?> _nextIndex(
    double index,
    Duration timeout,
  ) async {
    // Checks if the state is already available.
    if (_states.containsKey(index)) {
      return _states[index];
    }

    // Creates a completer if not already pending.
    _pendingIndexes.putIfAbsent(index, Completer<_FeaturesTourState>.new);

    try {
      return await _pendingIndexes[index]!.future.timeout(timeout);
    } on TimeoutException {
      _logger?.log(() => '   -> Timeout waiting for index $index.');
      _pendingIndexes.remove(index); // Cleans up the completer.
      return null;
    }
  }

  /// Waits until the page transition (and optional drawer animation) is complete.
  Future<void> _waitForTransition(BuildContext? context) async {
    if (context == null || !context.mounted) return;

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
  }

  /// Removes all controllers for a specific `pageName`.
  Future<void> _removePage({bool markAsShowed = true}) async {
    if (_states.isEmpty) {
      _logger?.log(() => '   -> Page $pageName has already been removed.');
      return;
    }

    _prefs ??= await SharedPreferences.getInstance();

    while (_states.isNotEmpty) {
      final state = _states.values.first;
      await _removeState(state, markAsShowed);
    }

    _logger?.log(() => '   -> Removing page: $pageName.');
  }

  /// Removes a specific state of this page.
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

  /// Checks whether there are any new features available to show the pre-dialog.
  bool _shouldShowIntroduction() {
    for (final state in _states.values) {
      final key = _getPrefKey(state);
      if (!_prefs!.containsKey(key) && state.context.mounted) {
        return true;
      }
    }

    return false;
  }

  /// Gets the key for shared preferences.
  String _getPrefKey(_FeaturesTourState state) {
    return '${FeaturesTour._prefix}_${pageName}_${state.widget.index}';
  }
}

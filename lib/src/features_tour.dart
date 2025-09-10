import 'dart:async';
import 'dart:collection';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/cover_dialog.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/components/features_child.dart';
import 'package:features_tour/src/components/unfeatures_tour.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'features_tour_controller.dart';
part 'utils/shared_prefs.dart';

/// The main widget for displaying a guided tour for a specific widget.
class FeaturesTour extends StatefulWidget {
  /// Creates a [FeaturesTour] to display a guided tour for a specific widget.
  ///
  /// This widget requires a [controller] of type [FeaturesTourController] and a [child] widget to wrap.
  /// You can use [childConfig] to customize the appearance or behavior of the child widget.
  ///
  /// The [index] is a unique identifier and determines the order in which widgets are shown.
  /// It is a `double`, which allows for the insertion of new features between existing ones.
  /// Ensure this value remains unchanged to prevent re-introducing the same feature unnecessarily.
  ///
  /// If [canPop] is `true`, the tour will be dismissed when popped. Otherwise,
  /// it blocks the current route from being popped.
  ///
  /// Use [nextIndex] to specify the next index to display.
  /// The app will pause user interaction until the specified index becomes available, making it ideal
  /// for scenarios like displaying a [FeaturesTour] in a dialog that opens after the current feature.
  /// To avoid a poor user experience, configure a timeout using [nextIndexTimeout], with a default of 3 seconds.
  /// Note that [nextIndex] only applies within the same [controller].
  ///
  /// You can disable a tour for specific widgets by setting [enabled] to `false`.
  /// This is particularly useful for lists where only one item should have the tour active.
  /// Set [enabled] to `false` for all other items.
  ///
  /// Use [introduce] to display introductory information, which can be customized with [introduceConfig].
  ///
  /// Configure the Next and Skip buttons using [nextConfig] and [skipConfig].
  ///
  /// To perform actions before or after the introduction, use [onBeforeIntroduce] and [onAfterIntroduce].
  /// In the [onAfterIntroduce] callback, you can access the [IntroduceResult] to determine
  /// whether the user pressed the Next or Skip button or if they tapped outside the introduction
  /// to dismiss it. This allows you to control the flow of the tour based on user interactions.
  const FeaturesTour({
    required this.controller,
    required this.index,
    required this.child,
    super.key,
    @Deprecated('Use `FeaturesTourController.start(popToSkip: true)` instead.')
    this.canPop = true,
    @Deprecated(
      'Use `nextIndex` instead. This will be removed in the next major version.',
    )
    double? waitForIndex,
    @Deprecated(
      'Use `nextIndexTimeout` instead. This will be removed in the next major version.',
    )
    Duration waitForTimeout = const Duration(seconds: 3),
    double? nextIndex,
    // TODO(lamnhan066): Set `nextIndexTimeout` to `Duration(seconds: 3)` in the next release candidate.
    Duration? nextIndexTimeout,
    this.childConfig,
    this.introduce = const SizedBox.shrink(),
    this.introduceConfig,
    this.nextConfig,
    this.skipConfig,
    this.doneConfig,
    this.enabled = true,
    this.onBeforeIntroduce,
    this.onAfterIntroduce,
  })  : nextIndex = nextIndex ?? waitForIndex,
        nextIndexTimeout = nextIndexTimeout ?? waitForTimeout;

  /// The prefix of this package.
  static String _prefix = 'FeaturesTour';

  /// The global force variable.
  static bool? _force;

  /// Allows printing the debug logs.
  static bool _debugLog = false;

  /// Sets the global configs.
  ///
  /// [force] to show or hide all the instructions, including pre-dialogs.
  /// The default is `null`, which means it depends on its own `start` configuration.
  ///
  /// [preferencePrefix] is the prefix for the shared preferences.
  ///
  /// [childConfig] to configure the child widget.
  ///
  /// [introduceConfig] to configure the introduce widget.
  ///
  /// [predialogConfig] to configure the pre-dialog widget.
  ///
  /// [skipConfig] and [nextConfig] to configure the Skip and Next buttons.
  ///
  /// [debugLog] allows printing the debug logs. The default is `kDebugMode`.
  ///
  /// Ex:
  /// ``` dart
  /// setGlobalConfig(
  ///   childConfig: ChildConfig(
  ///      backgroundColor : Colors.white,
  ///   ),
  ///   skipConfig: SkipConfig(
  ///     text: 'SKIP >>>',
  ///   ),
  ///   introduceConfig: IntroduceConfig(
  ///     backgroundColor = Colors.black,
  ///   ),
  /// );
  /// ```
  static void setGlobalConfig({
    /// Forces all [FeaturesTour] to be shown if this value is `true`, and not
    /// shown if this value is `false`. The default is `null`, which only shows
    /// if there are new [FeaturesTour]s.
    ///
    /// **You have to set this value to `null` before release to make the package
    /// work as expected.**
    bool? force,

    /// The prefix of the local database name to save the widget's showing state.
    /// The default is 'FeaturesTour'.
    String? preferencePrefix,

    /// The configuration of the fake [child] widget. The default is [ChildConfig.global].
    ChildConfig? childConfig,

    /// The configuration of the [introduce] widget. The default is [IntroduceConfig.global].
    IntroduceConfig? introduceConfig,

    /// The configuration of the [showPreDialog] widget. The default is [PreDialogConfig.global].
    @Deprecated(
      'Use `preDialogConfig` instead. This will be removed in the next major version.',
    )
    PreDialogConfig? predialogConfig,

    /// The configuration of the pre-dialog widget. The default is [PreDialogConfig.global].
    PreDialogConfig? preDialogConfig,

    /// The configuration of the skip button. The default is [SkipConfig.global].
    SkipConfig? skipConfig,

    /// The configuration of the next button. The default is [NextConfig.global].
    NextConfig? nextConfig,

    /// The configuration of the done button. The default is [DoneConfig.global].
    ///
    /// This button is only shown when the current introduction is the last and
    /// `doneConfig.enabled` is `true`.
    DoneConfig? doneConfig,

    /// Allows printing the debug logs. The default is `kDebugMode`.
    bool? debugLog,
  }) {
    assert(
      preDialogConfig == null || predialogConfig == null,
      'You can only set `predialogConfig` or `preDialogConfig`.',
    );
    if (force != null) _force = force;
    if (childConfig != null) ChildConfig.global = childConfig;
    if (skipConfig != null) SkipConfig.global = skipConfig;
    if (nextConfig != null) NextConfig.global = nextConfig;
    if (doneConfig != null) DoneConfig.global = doneConfig;
    if (introduceConfig != null) IntroduceConfig.global = introduceConfig;
    if (predialogConfig != null) PreDialogConfig.global = predialogConfig;
    if (preDialogConfig != null) PreDialogConfig.global = preDialogConfig;
    if (preferencePrefix != null) _prefix = preferencePrefix;
    if (debugLog != null) _debugLog = debugLog;
  }

  /// Removes all controllers for all pages.
  static Future<void> removeAll({bool markAsShowed = true}) async {
    for (final controller in FeaturesTourController._controllers) {
      await controller._removePage(markAsShowed: markAsShowed);
    }
    FeaturesTourController._controllers.clear();
    if (_debugLog) {
      debugPrint('All pages have been removed.');
    }
  }

  /// The controller for the current page, which is responsible for managing the tour.
  final FeaturesTourController controller;

  /// A unique index used to order the tour steps.
  /// This value must not be duplicated.
  final double index;

  /// Specifies the next [index] to start the tour.
  /// The plugin will wait for this index to appear or until [nextIndexTimeout] is reached.
  /// If set to `null`, the tour will proceed in the natural order of the [index].
  ///
  /// Note: This value applies only within the same [controller].
  ///
  /// Example: Use this to wait for a dialog to appear before displaying the next step.
  final double? nextIndex;

  /// The timeout duration for waiting on [nextIndex]. The default is 3 seconds.
  ///
  /// Ensure this value is not excessively long to maintain a good user experience.
  final Duration nextIndexTimeout;

  /// Determines whether this widget's actions are enabled.
  final bool enabled;

  /// The [child] will be wrapped with [PopScope] to control the pop behavior.
  ///
  /// If [canPop] is `true`, the tour will be dismissed when popped. Otherwise,
  /// it blocks the current route from being popped.
  @Deprecated('Use `FeaturesTourController.start(popToSkip: true)` instead.')
  final bool canPop;

  /// The child widget wrapped by [FeaturesTour].
  final Widget child;

  /// The widget used to introduce this feature in the tour.
  final Widget introduce;

  /// The configuration for the [introduce] widget.
  /// If `null`, the global configuration ([IntroduceConfig.global]) will be used.
  final IntroduceConfig? introduceConfig;

  /// The configuration for the "Next" button.
  /// If `null`, the global configuration ([NextConfig.global]) will be used.
  final NextConfig? nextConfig;

  /// The configuration for the "Skip" button.
  /// If `null`, the global configuration ([SkipConfig.global]) will be used.
  final SkipConfig? skipConfig;

  /// The configuration for the "Done" button.
  /// If `null`, the global configuration ([DoneConfig.global]) will be used.
  final DoneConfig? doneConfig;

  /// The configuration for the overlay widget displayed over the [child].
  /// If `null`, the global configuration ([ChildConfig.global]) will be used.
  final ChildConfig? childConfig;

  /// A callback that is triggered before the [introduce] widget is shown.
  ///
  /// This can be used to perform actions or preparations right before the introduction step appears.
  /// If the callback returns a [Future], the tour will wait for it to complete before proceeding.
  final FutureOr<void> Function()? onBeforeIntroduce;

  /// A callback that is triggered after the [introduce] widget is shown.
  ///
  /// This can be used to perform actions or preparations right after the introduction step appears.
  /// If the callback returns a [Future], the tour will wait for it to complete before
  /// proceeding to the next step.
  final FutureOr<void> Function(IntroduceResult introduceResult)?
      onAfterIntroduce;

  @override
  State<FeaturesTour> createState() => _FeaturesTourState();
}

class _FeaturesTourState extends State<FeaturesTour> {
  late bool isEnabled;
  bool _canPop = true;

  void _blockPop() {
    if (!_canPop) return;

    _canPop = false;
    if (mounted) setState(() {});
  }

  void _allowPop() {
    if (_canPop) return;

    _canPop = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (isEnabled) widget.controller._unregister(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final isUnfeaturesTour = UnfeaturesTour.isUnfeaturesTour(context);
    isEnabled = widget.enabled && !isUnfeaturesTour;
    if (isEnabled) widget.controller._register(this);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      key: isEnabled ? widget.controller._globalKeys[widget.index] : null,
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        widget.controller._handlePopScope();
      },
      child: widget.child,
    );
  }
}

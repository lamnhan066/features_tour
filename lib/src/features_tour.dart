import 'dart:async';
import 'dart:collection';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/components/unfeatures_tour.dart';
import 'package:features_tour/src/models/button_types.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/cover_dialog.dart';
import 'components/features_child.dart';

part 'features_tour_controller.dart';
part 'utils/print_debug.dart';
part 'utils/shared_prefs.dart';

class FeaturesTour extends StatelessWidget {
  /// Prefix of this package.
  static String _prefix = 'FeaturesTour';

  /// Global force variable.
  static bool? _force;

  /// Allow printing the debug logs.
  static bool _debugLog = false;

  /// Set the global configs.
  ///
  /// [force] to show all or hide all the instructions, including predialogs.
  /// Default is `null`, means it depends on it's own `start` configuration.
  ///
  /// [preferencePrefix] if the prefix of the shared preferences.
  ///
  /// [childConfig] to configure child widget.
  ///
  /// [introduceConfig] to configure introduce widget.
  ///
  /// [predialogConfig] to configure predialog widget.
  ///
  /// [skipConfig] and [nextConfig] to configure Skip and Next buttons.
  ///
  /// [debugLog] allow printing the debug logs. Default is `kDebugMode`.
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
    /// Force to show all the [FeaturesTour] if this value is `true` and force
    /// not to show it if this value is `false`. Default is `null`, only show
    /// if there are new [FeaturesTour]s.
    ///
    /// **You have to set this value to `null` before releasing to make the package
    /// works as expected**
    bool? force,

    /// Prefix of local database name to save the widget showing state
    /// Default is 'FeaturesTour'.
    String? preferencePrefix,

    /// Configuration of the fake [child] widget. Default is [ChildConfig.global].
    ChildConfig? childConfig,

    /// Configuration of the [introduce] widget. Default is [IntroduceConfig.global].
    IntroduceConfig? introduceConfig,

    /// Configuration of the predialog widget. Default is [PredialogConfig.global].
    PredialogConfig? predialogConfig,

    /// Configuration of the skip button. Default is [SkipConfig.global].
    SkipConfig? skipConfig,

    /// Configuration of the next button. Default is [NextConfig.global].
    NextConfig? nextConfig,

    /// Configuration of the done button. Default is [DoneConfig.global].
    ///
    /// This button only shows when the current introduction is the last and
    /// `doneConfig.enabled` is `true`.
    DoneConfig? doneConfig,

    /// Allow printing the debug logs. Default is `kDebugMode`.
    bool? debugLog,
  }) {
    if (force != null) _force = force;
    if (childConfig != null) ChildConfig.global = childConfig;
    if (skipConfig != null) SkipConfig.global = skipConfig;
    if (nextConfig != null) NextConfig.global = nextConfig;
    if (doneConfig != null) DoneConfig.global = doneConfig;
    if (introduceConfig != null) IntroduceConfig.global = introduceConfig;
    if (predialogConfig != null) PredialogConfig.global = predialogConfig;
    if (preferencePrefix != null) _prefix = preferencePrefix;
    if (debugLog != null) _debugLog = debugLog;
  }

  /// Removes all controllers for all pages.
  static Future<void> removeAll({bool markAsShowed = true}) async {
    for (final controller in FeaturesTourController._controllers) {
      await controller._removePage(markAsShowed: markAsShowed);
    }
    printDebug(() => 'All pages has been removed');
  }

  /// Get key for shared preferences.
  static String _getPrefKey(
    String? pageName,
    FeaturesTour state,
  ) {
    return '${_prefix}_${pageName}_${state.index}';
  }

  /// Creates a [FeaturesTour] to display a guided tour for a specific widget.
  ///
  /// This widget requires a [controller] of type [FeaturesTourController] and a [child] widget to wrap.
  /// You can use [childConfig] to customize the appearance or behavior of the child widget.
  ///
  /// The [index] is a unique identifier and determines the order in which widgets are shown.
  /// It is a `double`, allowing for insertion of new features between existing ones.
  /// Ensure this value remains unchanged to prevent reintroducing the same feature unnecessarily.
  ///
  /// If [canPop] is `true`, the tour will be dismissed when popped. Otherwise,
  /// it blocks the current route from being popped.
  ///
  /// Use [waitForIndex] to specify the next index to display.
  /// The app will pause interaction until the specified index becomes available, making it ideal
  /// for scenarios like displaying a [FeaturesTour] in a dialog that opens after the current feature.
  /// To avoid poor user experience, configure a timeout using [waitForTimeout], with a default of 3 seconds.
  /// Note that [waitForIndex] only applies within the same [controller].
  ///
  /// You can disable a tour for specific widgets by setting [enabled] to `false`.
  /// This is particularly useful for lists where only one item should have the tour active;
  /// set [enabled] to `false` for all other items.
  ///
  /// Use [introduce] to display introductory information, which can be customized with [introduceConfig].
  ///
  /// Configure the Next and Skip buttons using [nextConfig] and [skipConfig].
  ///
  /// The [onPressed] callback is triggered when this widget is pressed.
  /// If [onPressed] returns a `Future`, the next tour step will be delayed until the action completes.
  ///
  /// To perform actions before or after the introduction, use [onBeforeIntroduce] and [onAfterIntroduce].
  /// In the [onAfterIntroduce] callback, you can access the [IntroduceResult] to determine
  /// whether the user pressed the Next or Skip button, or if they tapped outside the introduction
  /// to dismiss it. This allows you to control the flow of the tour based on user interactions.
  const FeaturesTour({
    super.key,
    required this.controller,
    required this.index,
    this.canPop = true,
    this.waitForIndex,
    this.waitForTimeout = const Duration(seconds: 3),
    required this.child,
    this.childConfig,
    this.introduce = const SizedBox.shrink(),
    this.introduceConfig,
    this.nextConfig,
    this.skipConfig,
    this.doneConfig,
    this.enabled = true,
    this.onPressed,
    this.onBeforeIntroduce,
    this.onAfterIntroduce,
  }) : assert(onPressed == null || onAfterIntroduce == null,
            'Use `onAfterIntroduce` instead of `onPressed` to avoid confusion.');

  GlobalKey _resolveKey() {
    final globalKey = controller._globalKeys[index];

    if (globalKey != null) {
      return globalKey;
    }

    return GlobalObjectKey('${controller.pageName}-$index');
  }

  /// The controller for the current page, responsible for managing the tour.
  final FeaturesTourController controller;

  /// A unique index used to order the tour steps.
  /// This value must not be duplicated.
  final double index;

  /// Specifies the next [index] to start the tour.
  /// The plugin will wait for this index to appear or until the [waitForTimeout] is reached.
  /// If set to `null`, the tour will proceed in the natural order of the [index].
  ///
  /// Note: This value applies only within the same [controller].
  ///
  /// Example: Use this to wait for a dialog to appear before displaying the next step.
  final double? waitForIndex;

  /// The timeout duration for waiting on [waitForIndex]. Defaults to 3 seconds.
  ///
  /// Ensure this value is not excessively long to maintain a good user experience.
  final Duration waitForTimeout;

  /// Determines whether this widget's actions are enabled.
  final bool enabled;

  /// The [child] will be wrapped with the [PopScope] to control the pop behavior.
  ///
  /// If [canPop] is `true`, the tour will be dismissed when popped. Otherwise,
  /// it blocks the current route from being popped.
  final bool canPop;

  /// The child widget wrapped by the [FeaturesTour].
  final Widget child;

  /// The widget used to introduce this feature in the tour.
  final Widget introduce;

  /// Configuration for the [introduce] widget.
  /// If `null`, the global configuration ([IntroduceConfig.global]) will be used.
  final IntroduceConfig? introduceConfig;

  /// Configuration for the "Next" button.
  /// If `null`, the global configuration ([NextConfig.global]) will be used.
  final NextConfig? nextConfig;

  /// Configuration for the "Skip" button.
  /// If `null`, the global configuration ([SkipConfig.global]) will be used.
  final SkipConfig? skipConfig;

  /// Configuration for the "Done" button.
  /// If `null`, the global configuration ([DoneConfig.global]) will be used.
  final DoneConfig? doneConfig;

  /// Configuration for the overlay widget displayed over the [child].
  /// If `null`, the global configuration ([ChildConfig.global]) will be used.
  final ChildConfig? childConfig;

  /// Callback triggered when the [introduce] widget is tapped.
  ///
  /// Note: Interactions with widgets inside [introduce], such as buttons,
  /// will not be triggered. To include button functionality, add the button
  /// to both [child] and [onPressed].
  ///
  /// Example:
  /// ```dart
  /// FeaturesTour(
  ///   child: ElevatedButton(onPressed: onPressed, child: Text('Button')),
  ///   onPressed: onPressed,
  /// )
  /// ```
  @Deprecated('Use `onAfterIntroduce` instead.')
  final FutureOr<void> Function()? onPressed;

  /// Callback triggered before the [introduce] widget is shown.
  ///
  /// This can be used to perform actions or preparations right before the introduction step appears.
  /// If the callback returns a [Future], the tour will wait for it to complete before proceeding.
  final FutureOr<void> Function()? onBeforeIntroduce;

  /// Callback triggered after the [introduce] widget is shown.
  ///
  /// This can be used to perform actions or preparations right after the introduction step appears.
  /// If the callback returns a [Future], the tour will wait for it to complete before
  /// proceeding to the next step.
  final FutureOr<void> Function(IntroduceResult introduceResult)?
      onAfterIntroduce;

  /// Get the current context.
  BuildContext? get _context => _resolveKey().currentContext;

  @override
  Widget build(BuildContext context) {
    final isUnfeaturesTour = UnfeaturesTour.isUnfeaturesTour(context);
    final isEnabled = enabled && !isUnfeaturesTour;
    if (isEnabled) controller._register(this);

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (canPop) await controller._stop();
      },
      child: KeyedSubtree(
        key: isEnabled ? _resolveKey() : null,
        child: child,
      ),
    );
  }
}

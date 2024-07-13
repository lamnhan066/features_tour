import 'dart:async';
import 'dart:collection';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/components/dialogs.dart';
import 'package:features_tour/src/models/instruction_result.dart';
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

  /// Store all available controllers
  static final Set<FeaturesTourController> _controllers = {};

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
  ///   childConfig: ChildConfig.global.copyWith(
  ///      backgroundColor : Colors.white,
  ///   ),
  ///   skipConfig: SkipConfig.global.copyWith(
  ///     text: 'SKIP >>>',
  ///   ),
  ///   introduceConfig: IntroduceConfig.global.copyWith(
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
    for (final controller in _controllers) {
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

  /// Create a [FeaturesTour] to show the tour for specified widget.
  ///
  /// This widget only requires [controller] is [FeaturesTourController] and
  /// [child] is your widget. There is [childConfig] to configure the child widget.
  ///
  /// The [index] is a unique value and it's very important because it will decide
  /// which widget to show first due to its ordered, if you want the package to
  /// maintain it automatically then you just need to let it `null` for
  /// **all widgets in the same page**, if not you have to set it manually also
  /// for **all widgets in the same page**. I make this index as `double` because
  /// you can add new feature to between 2 other features. This number must be
  /// not changed if you don't want to introduce that feature again.
  ///
  /// You can specify the next index to show with [waitForIndex], the app will
  /// freeze until the next index is available (users cannot tap any where on the screen).
  /// It's useful when you want to show the [FeaturesTour] in the dialog that
  /// will be opened after this feature is shown. So please careful by using
  /// the [waitForTimeout] to specify the timeout for each action to avoid
  /// the bad UX, default timeout is 3 seconds. Remember that this index is only
  /// using in the same [controller].
  ///
  /// You can disable this feature by setting [enabled] to `false`. Especially,
  /// when you're using the [FeaturesTour] for items of a List, you can
  /// [enabled] only one of them, so you have to set the [enabled] of other items to `false`.
  ///
  /// [introduce] is a widget that will show the introduce information, you can
  /// also configure it with [introduceConfig].
  ///
  /// There are Next button and Skip button that you can configure it with [nextConfig]
  /// and [skipConfig].
  ///
  /// The [onPressed] will be triggered when this widget is pressed. This can be
  /// a `Future` method, the next introduction will be delayed until this method
  /// is completed.
  FeaturesTour({
    GlobalKey? key,
    required this.controller,

    /// The tour will sort by this index, and it must be not duplicated. You can
    /// leave this black if you want to let the package to control it automatically.
    required this.index,
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
  }) : super(
            key: enabled
                ? (key ?? controller._globalKeys[index] ?? GlobalKey())
                : null);

  /// Controller of the current page.
  final FeaturesTourController controller;

  /// The tour will sort by this index, and it must be not dupplicated. You can
  /// leave this black if you want to let the package to control it automatically.
  late final double index;

  /// This is the next index that you want to start. The plugin will wait for it
  /// until it's appeared or [waitForTimeout] is reached. If this value is `null`,
  /// the order of the [index] will be used.
  ///
  /// Remember that this index is only using in the same [controller].
  ///
  /// Ex: You want to wait for the dialog to appear to show the next introduction.
  final double? waitForIndex;

  /// Timeout when [waitForTimeout] is set. Defaults to 3 seconds.
  ///
  /// This value must not be to long to avoid UX issues.
  final Duration waitForTimeout;

  /// Enable or disable the action of this widget.
  final bool enabled;

  /// Child widget.
  final Widget child;

  /// Introduce this feature.
  final Widget introduce;

  /// Introduce widget config. If this value is `null`, the `IntroduceConfig.global` is used.
  final IntroduceConfig? introduceConfig;

  /// Next button config. If this value is `null`, the `NextConfig.global` is used.
  final NextConfig? nextConfig;

  /// Skip button config. If this value is `null`, the `SkipConfig.global` is used.
  final SkipConfig? skipConfig;

  /// Done button config. If this value is `null`, the `DoneConfig.global` is used.
  final DoneConfig? doneConfig;

  /// Child widget that shows up on the original child widget.  If this value is `null`,
  /// the `ChildConfig.global` is used.
  final ChildConfig? childConfig;

  /// Will be triggered when the `introduce` widget is tapped.
  ///
  /// Please notice that the widget inside it will not be triggered even it's a button.
  /// So if you want to trigger that button, you have to add it into both widgets.
  ///
  /// Ex:
  /// ```dart
  /// FeaturesTour(
  ///   child: ElevatedButton(onPressed: onPressed, child: Text('Button')),
  ///   onPressed: onPressed,
  /// )
  /// ```
  final FutureOr<void> Function()? onPressed;

  late final BuildContext _context;

  Future<IntroduceResult> showIntroduce(bool isLastState) async {
    if (!enabled) return IntroduceResult.disabled;

    if (!_context.mounted) return IntroduceResult.notMounted;

    final introduceConfig = this.introduceConfig ?? IntroduceConfig.global;
    final childConfig = this.childConfig ?? ChildConfig.global;
    final skipConfig = this.skipConfig ?? SkipConfig.global;
    final nextConfig = this.nextConfig ?? NextConfig.global;
    final doneConfig = this.doneConfig ?? DoneConfig.global;

    final completer = Completer<IntroduceResult?>();
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(builder: (ctx) {
      return GestureDetector(
        onTap: childConfig.barrierDismissible
            ? () {
                completer.complete(null);
                overlayEntry.remove();
              }
            : null,
        child: Material(
          color: introduceConfig.backgroundColor,
          child: FeaturesChild(
            globalKey: key as GlobalKey,
            childConfig: childConfig,
            introduce: introduce,
            skip: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: skipConfig.child != null
                    ? skipConfig.child!(() {
                        completer.complete(IntroduceResult.skip);
                        overlayEntry.remove();
                      })
                    : ElevatedButton(
                        onPressed: () {
                          completer.complete(IntroduceResult.skip);
                          overlayEntry.remove();
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
                        completer.complete(IntroduceResult.next);
                        overlayEntry.remove();
                      })
                    : ElevatedButton(
                        onPressed: () {
                          completer.complete(IntroduceResult.next);
                          overlayEntry.remove();
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
                        completer.complete(IntroduceResult.done);
                        overlayEntry.remove();
                      })
                    : ElevatedButton(
                        onPressed: () {
                          completer.complete(IntroduceResult.done);
                          overlayEntry.remove();
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
                completer.complete(IntroduceResult.next);
                overlayEntry.remove();
              },
              child: Material(
                color: childConfig.backgroundColor,
                type: MaterialType.canvas,
                child: AbsorbPointer(
                  absorbing: true,
                  child: childConfig.child == null
                      ? child
                      : childConfig.child!(child),
                ),
              ),
            ),
          ),
        ),
      );
    });
    Overlay.of(_context).insert(overlayEntry);

    /// Closed by the `barrierDismissible`.
    final result = (await completer.future) ?? IntroduceResult.next;

    if (onPressed != null) {
      Future<void> callOnPressed() async {
        Completer completer = Completer();
        completer.complete(onPressed!());
        await completer.future;
      }

      switch (result) {
        case IntroduceResult.disabled:
        case IntroduceResult.notMounted:
          break;
        case IntroduceResult.skip:
          if (skipConfig.isCallOnPressed) {
            await callOnPressed();
          }
          break;
        case IntroduceResult.next:
        case IntroduceResult.done:
          await callOnPressed();
          break;
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    try {
      _context = context;
    } catch (_) {}
    if (enabled) controller._register(this);
    return child;
  }
}

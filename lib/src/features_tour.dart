import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/models/instruction_result.dart';
import 'package:features_tour/src/utils/dialogs.dart';
import 'package:features_tour/src/utils/print_debug.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/features_child.dart';
import 'components/features_tour_minxin.dart';

part 'features_tour_controller.dart';

class FeaturesTour extends StatefulWidget {
  /// Prefix of this package
  static String _prefix = 'FeaturesTour';

  /// Global force variable
  static bool _force = false;

  /// Store all available controllers
  static final List<FeaturesTourController> _controllers = [];

  /// Set the global configs
  ///
  /// [force] to show the instructions
  ///
  /// [preferencePrefix] if the prefix of the shared preferences
  ///
  /// [childConfig] to configure child widget
  ///
  /// [introduceConfig] to configure introduce widget
  ///
  /// [predialogConfig] to configure predialog widget
  ///
  /// [skipConfig] and [nextConfig] to configure Skip and Next buttons
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
    /// Force to show all the tours. Default is `false`.
    bool? force,

    /// Prefix of local database name to save the widget showing state
    /// Default is 'FeaturesTour'.
    String? preferencePrefix,

    /// Configuration of the fake [child] widget. Default is [ChildConfig.global].
    ChildConfig? childConfig,

    /// Configuration of the [introduce] widget. Default is [IntroduceConfig.global].
    IntroduceConfig? introduceConfig,

    /// Configuration of the predialog widget. Default is [PredialogConfig.global
    PredialogConfig? predialogConfig,

    /// Configuration of the skip button. Default is [SkipConfig.global].
    SkipConfig? skipConfig,

    /// Configuration of the next button. Default is [NextConfig.global].
    NextConfig? nextConfig,
  }) {
    if (force != null) _force = force;
    if (childConfig != null) ChildConfig.global = childConfig;
    if (skipConfig != null) SkipConfig.global = skipConfig;
    if (nextConfig != null) NextConfig.global = nextConfig;
    if (introduceConfig != null) IntroduceConfig.global = introduceConfig;
    if (predialogConfig != null) PredialogConfig.global = predialogConfig;
    if (preferencePrefix != null) _prefix = preferencePrefix;
  }

  /// Removes all controllers for all pages
  static Future<void> removeAll({bool markAsShowed = true}) async {
    for (final controller in _controllers) {
      await controller._removePage(markAsShowed: markAsShowed);
    }
    printDebug('All pages has been removed');
  }

  /// Get key for shared preferences
  static String _getPrefKey(
    String? pageName,
    FeaturesTourStateMixin controller,
  ) {
    return '${_prefix}_${pageName}_${controller.index}';
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
  /// You can disable this feature by using [enabled].
  ///
  /// [introduce] is a widget that will show the introduce information, you can
  /// also configure it with [introduceConfig].
  ///
  /// There are Next button and Skip button that you can configure it with [nextConfig]
  /// and [skipConfig].
  ///
  /// The [onPressed] will be triggered when this widget is pressed.
  FeaturesTour({
    required this.controller,
    double? index,
    required this.child,
    this.childConfig,
    this.introduce = const SizedBox.shrink(),
    this.introduceConfig,
    this.nextConfig,
    this.skipConfig,
    this.enabled = true,
    this.onPressed,
  }) : super(key: GlobalKey()) {
    this.index = index ?? controller._getAutoIndex;
  }

  /// Controller of the current page
  final FeaturesTourController controller;

  /// The tour will sort by this index, and it must be not dupplicated. You can
  /// leave this black if you want to let the package to control it automatically.
  late final double index;

  /// Enable or disable the action of this widget
  final bool enabled;

  /// Child widget
  final Widget child;

  /// Introduce this feature
  final Widget introduce;

  /// Introduce widget config. If this value is `null`, the `IntroduceConfig.global` is used.
  final IntroduceConfig? introduceConfig;

  /// Next button config. If this value is `null`, the `NextConfig.global` is used.
  final NextConfig? nextConfig;

  /// Skip button config. If this value is `null`, the `SkipConfig.global` is used.
  final SkipConfig? skipConfig;

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
  ///   globalKey: GlobalKey(),
  ///   child: ElevatedButton(onPressed: onPressed, child: Text('Button')),
  ///   onPressed: onPressed,
  /// )
  /// ```
  final void Function()? onPressed;

  @override
  State<FeaturesTour> createState() => _FeaturesTourState();
}

class _FeaturesTourState extends State<FeaturesTour>
    with FeaturesTourStateMixin {
  @override
  double get index => widget.index;

  @override
  Future<IntroduceResult> showIntroduce(
    FeaturesTourStateMixin calledState,
  ) async {
    if (!widget.enabled) return IntroduceResult.disabled;

    if (!mounted) return IntroduceResult.notMounted;

    // Avoid calling in the wrong state
    if (this != calledState) return IntroduceResult.wrongState;

    final introduceConfig = widget.introduceConfig ?? IntroduceConfig.global;
    final childConfig = widget.childConfig ?? ChildConfig.global;
    final skipConfig = widget.skipConfig ?? SkipConfig.global;
    final nextConfig = widget.nextConfig ?? NextConfig.global;

    final result = await showDialog<IntroduceResult>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: introduceConfig.backgroundColor,
      builder: (ctx) {
        return FeaturesChild(
          globalKey: widget.key as GlobalKey,
          introduce: widget.introduce,
          skip: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextButton(
                onPressed: () async {
                  if (ctx.mounted) {
                    Navigator.pop(ctx, IntroduceResult.skip);
                  }
                },
                child: Text(
                  skipConfig.text,
                  style: TextStyle(color: skipConfig.color),
                ),
              ),
            ),
          ),
          skipConfig: skipConfig,
          next: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextButton(
                onPressed: () async {
                  if (ctx.mounted) {
                    Navigator.pop(ctx, IntroduceResult.next);
                  }

                  if (widget.onPressed != null) {
                    widget.onPressed!();
                  }
                },
                child: Text(
                  nextConfig.text,
                  style: TextStyle(color: nextConfig.color),
                ),
              ),
            ),
          ),
          nextConfig: nextConfig,
          padding: introduceConfig.padding,
          curve: childConfig.curve,
          zoomScale: childConfig.zoomScale,
          alignment: introduceConfig.alignment,
          quadrantAlignment: introduceConfig.quadrantAlignment,
          animationDuration: childConfig.animationDuration,
          child: GestureDetector(
            onTap: () async {
              if (ctx.mounted) {
                Navigator.pop(ctx, IntroduceResult.next);
              }

              if (widget.onPressed != null) {
                widget.onPressed!();
              }
            },
            child: Material(
              color: childConfig.backgroundColor,
              type: MaterialType.canvas,
              borderRadius: childConfig.borderRadius,
              shape: childConfig.shapeBorder,
              child: AbsorbPointer(
                absorbing: true,
                child: childConfig.child ?? widget.child,
              ),
            ),
          ),
        );
      },
    );

    if (result == null) {
      return IntroduceResult.notMounted;
    }

    return result;
  }

  @override
  void initState() {
    if (widget.enabled) widget.controller._register(this);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.enabled) widget.controller._unregister(this);
    super.dispose();
  }

  @override
  void reassemble() {
    // To make the `assert` works when debugging
    if (widget.enabled) widget.controller._unregister(this);
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

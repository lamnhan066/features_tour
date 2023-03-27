import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/utils/print_debug.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/features_child.dart';
import 'components/features_tour_minxin.dart';

part 'features_tour_controller.dart';

class FeaturesTour extends StatefulWidget {
  /// Prefix of this package
  static String _prefix = 'FeaturesTour';

  /// Store all available controllers
  static final List<FeaturesTourController> _controllers = [];

  /// Set the global configs
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
  ///   introdureConfig: IntrodureConfig.global.copyWith(
  ///     backgroundColor = Colors.black,
  ///   ),
  /// );
  /// ```
  static void setGlobalConfig({
    ChildConfig? childConfig,
    SkipConfig? skipConfig,
    NextConfig? nextConfig,
    IntrodureConfig? introdureConfig,
    String? preferencePrefix,
  }) {
    if (childConfig != null) ChildConfig.global = childConfig;
    if (skipConfig != null) SkipConfig.global = skipConfig;
    if (nextConfig != null) NextConfig.global = nextConfig;
    if (introdureConfig != null) IntrodureConfig.global = introdureConfig;
    if (preferencePrefix != null) _prefix = preferencePrefix;
  }

  /// Removes all controllers for all pages
  static Future<void> removeAll({bool markAsShowed = true}) async {
    for (final controller in _controllers) {
      await controller.removePage(markAsShowed: markAsShowed);
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
  /// for **all widgets in the same page**.
  ///
  /// You can disable this feature by using [enabled].
  ///
  /// [introdure] is a widget that will show the introdure information, you can
  /// also configure it with [introdureConfig].
  ///
  /// There are Next button and Skip button that you can configure it with [nextConfig]
  /// and [skipConfig].
  ///
  /// The [onPressed] will be triggered when this widget is pressed.
  FeaturesTour({
    required this.controller,
    int? index,
    required this.child,
    this.childConfig,
    this.introdure = const SizedBox.shrink(),
    this.introdureConfig,
    this.nextConfig,
    this.skipConfig,
    this.enabled = true,
    this.onPressed,
  }) : super(key: GlobalKey()) {
    this.index = index ?? controller.autoIndex;
  }

  /// Controller of the current page
  final FeaturesTourController controller;

  /// The tour will sort by this index, and it must be not dupplicated. You can
  /// leave this black if you want to let the package to control it automatically.
  late final int index;

  /// Enable or disable the action of this widget
  final bool enabled;

  /// Child widget
  final Widget child;

  /// Introdure this feature
  final Widget introdure;

  /// Introdure widget config. If this value is `null`, the `IntrodureConfig.global` is used.
  final IntrodureConfig? introdureConfig;

  /// Next button config. If this value is `null`, the `NextConfig.global` is used.
  final NextConfig? nextConfig;

  /// Skip button config. If this value is `null`, the `SkipConfig.global` is used.
  final SkipConfig? skipConfig;

  /// Child widget that shows up on the original child widget.  If this value is `null`,
  /// the `ChildConfig.global` is used.
  final ChildConfig? childConfig;

  /// Will be triggered when the `introdure` widget is tapped.
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
  int get index => widget.index;

  @override
  Future<void> showIntrodure() async {
    if (!widget.enabled) return;
    if (!mounted) return;

    final introdureConfig = widget.introdureConfig ?? IntrodureConfig.global;
    final childConfig = widget.childConfig ?? ChildConfig.global;
    final skipConfig = widget.skipConfig ?? SkipConfig.global;
    final nextConfig = widget.nextConfig ?? NextConfig.global;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: introdureConfig.backgroundColor,
      builder: (ctx) {
        return FeaturesChild(
          globalKey: widget.key as GlobalKey,
          introdure: widget.introdure,
          skip: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextButton(
                onPressed: () async {
                  await widget.controller.removePage(
                    markAsShowed: true,
                  );

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
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
                    Navigator.pop(ctx);
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
          padding: introdureConfig.padding,
          curve: childConfig.curve,
          zoomScale: childConfig.zoomScale,
          alignment: introdureConfig.alignment,
          quadrantAlignment: introdureConfig.quadrantAlignment,
          animationDuration: childConfig.animationDuration,
          child: GestureDetector(
            onTap: () async {
              if (ctx.mounted) {
                Navigator.pop(ctx);
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

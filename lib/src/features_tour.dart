import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/features_child.dart';

part 'features_tour_controller.dart';

class FeaturesTour extends StatefulWidget {
  /// Prefix of this package
  static String prefix = 'FeaturesTour';

  /// Internal preferences
  static SharedPreferences? _prefs;

  /// Controls the recent name
  static String? _recentName;

  /// Internal list of the controllers
  static final Map<String, List<_FeaturesTourStateMixin>> _controllers = {};

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
  }) {
    if (childConfig != null) ChildConfig.global = childConfig;
    if (skipConfig != null) SkipConfig.global = skipConfig;
    if (nextConfig != null) NextConfig.global = nextConfig;
    if (introdureConfig != null) IntrodureConfig.global = introdureConfig;
  }

  /// Set current page name
  static void setPageName(String name) {
    _controllers.addAll({name: []});
    _recentName = name;
  }

  /// Start the tour. This packaga automatically save the state of the widget,
  /// so it will skip the showed widget.
  ///
  /// Please note that the page navigation may affect this widget, so if you add
  /// this method to `initState`, you should delay for a second before calling this.
  ///
  /// Ex:
  /// ``` dart
  /// void initState() {
  ///   Timer(Duration(seconds:1), () {
  ///     FeaturesTour.start();
  ///   });
  /// }
  /// ```
  static Future<void> start({
    /// If this `context` is not null, it will be used to wait for the page
    /// transition to complete before showing the instructions.
    BuildContext? context,

    /// Start this page
    String? pageName,

    /// Forces show up on the instructions.
    bool isDebug = false,
  }) async {
    _prefs ??= await SharedPreferences.getInstance();

    if (context != null && context.mounted) {
      final modalRoute = ModalRoute.of(context)?.animation;
      Completer completer = Completer();

      if (modalRoute == null ||
          modalRoute.isCompleted ||
          modalRoute.isDismissed) {
        if (!completer.isCompleted) completer.complete();
      } else {
        modalRoute.addStatusListener((status) {
          if (status == AnimationStatus.completed ||
              status == AnimationStatus.dismissed) {
            if (!completer.isCompleted) completer.complete();
          }
        });
      }

      await completer.future;
    }

    final controllers = _controllers[pageName]!;
    controllers.sort((a, b) => a.index.compareTo(b.index));
    while (controllers.isNotEmpty) {
      final controller = controllers.removeAt(0);
      // ignore: use_build_context_synchronously
      final key = _getPrefKey(pageName, controller);
      print(key);

      if (_prefs!.getBool(key) != true || isDebug) {
        await controller.showIntrodure();
      }

      await _prefs!.setBool(key, true);
    }
  }

  /// Removes all controllers for specific `pageName`
  static Future<void> removePage({
    String? pageName,
    bool markAsShowed = true,
  }) async {
    if (_controllers.containsKey(pageName)) return;

    _prefs ??= await SharedPreferences.getInstance();
    final values = _controllers[pageName]!;

    for (final value in values) {
      if (markAsShowed) {
        // ignore: use_build_context_synchronously
        final key = _getPrefKey(pageName, value);
        await _prefs!.setBool(key, true);
      }
    }

    _controllers.remove(pageName);
  }

  static Future<void> removeAll({bool markAsShowed = true}) async {
    for (final page in _controllers.keys) {
      await removePage(pageName: page, markAsShowed: markAsShowed);
    }
  }

  static String _getPrefKey(
    String? pageName,
    _FeaturesTourStateMixin controller,
  ) {
    return '${prefix}_${pageName}_${controller.name}_${controller.index}';
  }

  const FeaturesTour({
    required GlobalKey key,
    required this.index,
    this.name,
    required this.child,
    this.childConfig,
    this.introdure = const SizedBox.shrink(),
    this.introdureConfig,
    this.nextConfig,
    this.skipConfig,
    this.enabled = true,
    this.onPressed,
  }) : super(key: key);

  // final GlobalKey globalKey;

  /// The tour will sort by this index, and it must be not dupplicated.
  final int index;

  /// Name of this widget, it will be used to save the status of this widget.
  ///
  /// If this value is `null` than `index` will be used insteads.
  final String? name;

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
    with _FeaturesTourStateMixin {
  bool isVisible = true;
  int? persistedIndex;

  IntrodureConfig introdureConfig = IntrodureConfig.global;
  ChildConfig childConfig = ChildConfig.global;
  SkipConfig skipConfig = SkipConfig.global;
  NextConfig nextConfig = NextConfig.global;

  @override
  int get index => widget.index;

  @override
  String get name => widget.name ?? index.toString();

  @override
  String? pageName = FeaturesTour._recentName;

  @override
  Future<void> showIntrodure() async {
    if (!widget.enabled) return;
    if (!mounted) return;

    introdureConfig = widget.introdureConfig ?? IntrodureConfig.global;
    childConfig = widget.childConfig ?? ChildConfig.global;
    skipConfig = widget.skipConfig ?? SkipConfig.global;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: introdureConfig.backgroundColor,
      builder: (ctx) {
        return FeaturesChild(
          globalKey: widget.key as GlobalKey,
          introdure: widget.introdure,
          skip: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextButton(
              onPressed: () async {
                await FeaturesTour.removePage(
                    pageName: pageName, markAsShowed: true);

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
          skipConfig: skipConfig,
          next: Padding(
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
          nextConfig: nextConfig,
          padding: introdureConfig.padding,
          curve: childConfig.curve,
          zoomScale: childConfig.zoomScale,
          alignment: introdureConfig.alignment,
          quadrantAlignment: introdureConfig.quadrantAlignment,
          animationDuration: introdureConfig.animationDuration,
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
    if (widget.enabled) featuresTourInitial();
    super.initState();
  }

  @override
  void dispose() {
    if (widget.enabled) featuresTourDispose();
    super.dispose();
  }

  @override
  void reassemble() {
    // To make the `assert` works when debugging
    if (widget.enabled) featuresTourDispose();
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'features_tour_controller.dart';

class FeaturesTour extends StatefulWidget {
  const FeaturesTour({
    required this.globalKey,
    this.index,
    this.name,
    required this.child,
    this.onTap,
    this.introdure = const SizedBox.shrink(),
    this.backgroundColor = Colors.black54,
    this.padding = const EdgeInsets.all(20.0),
    this.curve = Curves.decelerate,
    this.zoomScale = 1.5,
    this.horizontalAligment = HorizontalAligment.center,
    this.verticalAlignment = VerticalAlignment.top,
    this.animationDuration = const Duration(milliseconds: 600),
  }) : super(key: globalKey);

  /// Add a `GlobalKey()` to control this widget
  final GlobalKey globalKey;

  /// The tour will sort by this index, and it must be not dupplicated.
  ///
  /// If this value is `null`, it will be indexed automatically depends on
  /// the build order of the widget.
  ///
  /// Please notice that it may conflict with each others if you're using both
  /// `index` and auto indexed on the same screen.
  final int? index;

  /// Name of this widget, it will be used to save the status of this widget.
  ///
  /// If this value is `null` than `index` will be used insteads.
  final String? name;

  /// Child widget
  final Widget child;

  /// Feature introduction widget, normally `Text`
  final Widget introdure;

  /// Color of the background
  final Color backgroundColor;

  /// Padding of the `introdure` widget
  final EdgeInsetsGeometry padding;

  /// Will be triggered when the `introdure` widget is tapped. Please notice that
  /// the widget inside it will not be triggered even it's a button.
  final VoidCallback? onTap;

  /// Horizontal alignment of the `introdure` widget
  final HorizontalAligment horizontalAligment;

  /// Vertical alignment of the `introdure` widget
  final VerticalAlignment verticalAlignment;

  /// Zoom scale of the `child` widget when show up on the instruction
  final double zoomScale;

  /// Animation of the `child` widget when show up on the instruction
  final Curve curve;

  /// Animation duration of the `child` widget when show up on the instruction
  final Duration animationDuration;

  @override
  State<FeaturesTour> createState() => _FeaturesTourState();
}

class _FeaturesTourState extends State<FeaturesTour>
    with FeaturesTourController {
  bool isVisible = true;

  @override
  int get _index => widget.index ?? FeaturesTourController._autoIndex;

  @override
  String get _name => widget.name ?? _index.toString();

  @override
  Future<void> _showIntrodure() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      barrierColor: widget.backgroundColor,
      builder: (ctx) {
        return FeaturesChild(
          globalKey: widget.globalKey,
          introdure: widget.introdure,
          padding: widget.padding,
          curve: widget.curve,
          zoomScale: widget.zoomScale,
          horizontalAligment: widget.horizontalAligment,
          verticalAlignment: widget.verticalAlignment,
          animationDuration: widget.animationDuration,
          child: GestureDetector(
            onTap: () {
              if (widget.onTap != null) widget.onTap!();

              Navigator.pop(ctx);
            },
            child: AbsorbPointer(
              absorbing: true,
              child: widget.child,
            ),
          ),
        );
      },
    );

    super._showIntrodure();
  }

  @override
  void initState() {
    _featuresTourInitial();
    super.initState();
  }

  @override
  void dispose() {
    _featuresTourDispose();
    super.dispose();
  }

  @override
  void reassemble() {
    // To make the `assert` works when debugging
    _featuresTourDispose();
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'dart:async';

import 'package:features_tour/src/extensions/get_widget_position.dart';
import 'package:features_tour/src/models/alignment.dart';
import 'package:flutter/material.dart';

class FeaturesChild extends StatefulWidget {
  const FeaturesChild({
    super.key,
    required this.globalKey,
    required this.child,
    required this.skip,
    required this.skipAlignment,
    required this.introdure,
    required this.padding,
    required this.curve,
    required this.zoomScale,
    required this.animationDuration,
    this.alignment,
    required this.quadrantAlignment,
  });

  /// Add a `GlobalKey()` to control this widget
  final GlobalKey globalKey;

  /// Child widget
  final Widget child;

  /// Skip all the steps
  final Widget skip;

  /// Position of the skip widget
  final Alignment skipAlignment;

  /// Feature introduction widget, normally `Text`
  final Widget introdure;

  /// Padding of the `introdure` widget
  final EdgeInsetsGeometry padding;

  /// Alignmnent of the `introdure` widget in side `quarantAlignment`.
  ///
  /// This value automatically aligns depending on the `quarantAlignment`.
  /// Make it as close as possible to other.
  final Alignment? alignment;

  /// Quadrant rectangle for `introdure` widget.
  final QuadrantAlignment quadrantAlignment;

  /// Horizontal alignment of the `introdure` widget
  // final HorizontalAligment horizontalAligment;

  /// Vertical alignment of the `introdure` widget
  // final VerticalAlignment verticalAlignment;

  /// Zoom scale of the `child` widget when show up on the instruction
  final double zoomScale;

  /// Animation of the `child` widget when show up on the instruction
  final Curve curve;

  /// Animation duration of the `child` widget when show up on the instruction
  final Duration animationDuration;
  @override
  State<FeaturesChild> createState() => _FeaturesChildState();
}

class _FeaturesChildState extends State<FeaturesChild>
    with WidgetsBindingObserver {
  double scale = 1;
  Rect? rect;
  late Rect introdureRect;
  late Alignment alignment;

  void updateState() {
    rect = (widget.globalKey).globalPaintBounds;
    if (rect == null) return;

    final size = MediaQuery.of(context).size;
    switch (widget.quadrantAlignment) {
      case QuadrantAlignment.top:
        introdureRect = Rect.fromLTRB(0, 0, size.width, rect!.top);
        alignment = widget.alignment ?? Alignment.bottomCenter;
        break;
      case QuadrantAlignment.left:
        introdureRect = Rect.fromLTRB(0, 0, rect!.left, size.height);
        alignment = widget.alignment ?? Alignment.centerRight;
        break;
      case QuadrantAlignment.right:
        introdureRect = Rect.fromLTRB(rect!.right, 0, size.width, size.height);
        alignment = widget.alignment ?? Alignment.centerLeft;
        break;
      case QuadrantAlignment.bottom:
        introdureRect = Rect.fromLTRB(0, rect!.bottom, size.width, size.height);
        alignment = widget.alignment ?? Alignment.topCenter;
        break;
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        updateState();
      });

      // Control the animation of the `introdure` widget.
      Timer.periodic(widget.animationDuration, (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (scale == 1) {
          setState(() {
            scale = widget.zoomScale;
          });
        } else if (scale == widget.zoomScale) {
          setState(() {
            scale = 1;
          });
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {
      updateState();
    });

    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return rect == null
        ? const CircularProgressIndicator()
        : Stack(
            children: [
              Positioned.fromRect(
                rect: rect!,
                child: AnimatedScale(
                  scale: scale,
                  curve: widget.curve,
                  duration: widget.animationDuration,
                  child: widget.child,
                ),
              ),
              Positioned.fromRect(
                rect: introdureRect,
                child: Padding(
                  padding: widget.padding,
                  child: Align(
                    alignment: alignment,
                    child: widget.introdure,
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: widget.skipAlignment,
                  child: widget.skip,
                ),
              ),
            ],
          );
  }
}

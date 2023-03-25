import 'dart:async';

import 'package:features_tour/src/extensions/get_widget_position.dart';
import 'package:features_tour/src/models/aligment.dart';
import 'package:flutter/material.dart';

class FeaturesChild extends StatefulWidget {
  const FeaturesChild({
    super.key,
    required this.globalKey,
    required this.child,
    required this.introdure,
    required this.padding,
    required this.curve,
    required this.zoomScale,
    required this.animationDuration,
    required this.horizontalAligment,
    required this.verticalAlignment,
  });

  /// Add a `GlobalKey()` to control this widget
  final GlobalKey globalKey;

  /// Child widget
  final Widget child;

  /// Feature introduction widget, normally `Text`
  final Widget introdure;

  /// Padding of the `introdure` widget
  final EdgeInsetsGeometry padding;

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
  State<FeaturesChild> createState() => _FeaturesChildState();
}

class _FeaturesChildState extends State<FeaturesChild>
    with WidgetsBindingObserver {
  double scale = 1;
  Rect? rect;
  Rect? introdureRect;
  Alignment? alignment;

  void updateState() {
    rect = (widget.globalKey).globalPaintBounds;
    if (rect == null) return;

    final size = MediaQuery.of(context).size;
    switch (widget.verticalAlignment) {
      case VerticalAlignment.top:
        introdureRect = Rect.fromLTRB(0, 0, size.width, rect!.top);

        switch (widget.horizontalAligment) {
          case HorizontalAligment.left:
            alignment = Alignment.bottomLeft;
            break;
          case HorizontalAligment.center:
            alignment = Alignment.bottomCenter;
            break;
          case HorizontalAligment.right:
            alignment = Alignment.bottomRight;
            break;
        }
        break;
      case VerticalAlignment.bottom:
        introdureRect = Rect.fromLTRB(0, rect!.bottom, size.width, size.height);

        switch (widget.horizontalAligment) {
          case HorizontalAligment.left:
            alignment = Alignment.topLeft;
            break;
          case HorizontalAligment.center:
            alignment = Alignment.topCenter;
            break;
          case HorizontalAligment.right:
            alignment = Alignment.topRight;
            break;
        }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    return rect == null || introdureRect == null
        ? const CircularProgressIndicator()
        : Stack(
            clipBehavior: Clip.none,
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
                rect: introdureRect!,
                child: Padding(
                  padding: widget.padding,
                  child: Align(
                    alignment: alignment!,
                    child: widget.introdure,
                  ),
                ),
              ),
            ],
          );
  }
}

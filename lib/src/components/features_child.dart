import 'dart:async';

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/extensions/get_widget_position.dart';
import 'package:flutter/material.dart';

class FeaturesChild extends StatefulWidget {
  /// Internal widget to show all the needed widgets in Stack.
  const FeaturesChild({
    super.key,
    required this.globalKey,
    required this.child,
    required this.childConfig,
    required this.skip,
    required this.skipConfig,
    required this.next,
    required this.nextConfig,
    required this.introduce,
    required this.padding,
    this.alignment,
    required this.quadrantAlignment,
  });

  /// Add a `GlobalKey()` to control this widget.
  final GlobalKey globalKey;

  /// Child widget.
  final Widget child;

  /// Child configuration.
  final ChildConfig childConfig;

  /// Skip Button widget.
  final Widget skip;

  /// Skip all the steps.
  final SkipConfig skipConfig;

  /// Next button widget.
  final Widget next;

  /// Skip all the steps.
  final NextConfig nextConfig;

  /// Feature introduction widget, normally `Text`.
  final Widget introduce;

  /// Padding of the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// Alignmnent of the `introduce` widget in side `quarantAlignment`.
  ///
  /// This value automatically aligns depending on the `quarantAlignment`.
  /// Make it as close as possible to other.
  final Alignment? alignment;

  /// Quadrant rectangle for `introduce` widget.
  final QuadrantAlignment quadrantAlignment;

  @override
  State<FeaturesChild> createState() => _FeaturesChildState();
}

class _FeaturesChildState extends State<FeaturesChild>
    with WidgetsBindingObserver {
  double scale = 1;
  Rect? rect;
  late Rect introduceRect;
  late Alignment alignment;

  /// Update the current state.
  void updateState() {
    rect = (widget.globalKey).globalPaintBounds;
    if (rect == null) return;

    final size = MediaQuery.of(context).size;
    switch (widget.quadrantAlignment) {
      case QuadrantAlignment.top:
        introduceRect = Rect.fromLTRB(0, 0, size.width, rect!.top);
        alignment = widget.alignment ?? Alignment.bottomCenter;
        break;
      case QuadrantAlignment.left:
        introduceRect = Rect.fromLTRB(0, 0, rect!.left, size.height);
        alignment = widget.alignment ?? Alignment.centerRight;
        break;
      case QuadrantAlignment.right:
        introduceRect = Rect.fromLTRB(rect!.right, 0, size.width, size.height);
        alignment = widget.alignment ?? Alignment.centerLeft;
        break;
      case QuadrantAlignment.bottom:
        introduceRect = Rect.fromLTRB(0, rect!.bottom, size.width, size.height);
        alignment = widget.alignment ?? Alignment.topCenter;
        break;
      case QuadrantAlignment.inside:
        introduceRect = rect!;
        alignment = widget.alignment ?? Alignment.center;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        scale = widget.childConfig.zoomScale;
      });
      // Control the animation of the `introduce` widget.
      Timer.periodic(widget.childConfig.animationDuration, (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (scale == 1) {
          setState(() {
            scale = widget.childConfig.zoomScale;
          });
        } else if (scale == widget.childConfig.zoomScale) {
          setState(() {
            scale = 1;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    setState(() {
      updateState();
    });
    super.didChangeDependencies();
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
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // Border widget
              Positioned.fromRect(
                rect: rect!.inflate(widget.childConfig.borderSizeInflate),
                child: AnimatedScale(
                  scale: scale,
                  curve: widget.childConfig.curve,
                  duration: widget.childConfig.animationDuration,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.childConfig.backgroundColor,
                      borderRadius: widget.childConfig.borderRadius,
                    ),
                  ),
                ),
              ),

              // Child widget.
              if (widget.childConfig.isAnimateChild)
                Positioned.fromRect(
                  rect: rect!,
                  child: AnimatedScale(
                    scale: scale,
                    curve: widget.childConfig.curve,
                    duration: widget.childConfig.animationDuration,
                    child: widget.child,
                  ),
                )
              else
                Positioned.fromRect(
                  rect: rect!,
                  child: widget.child,
                ),

              // Introduction widget.
              Positioned.fromRect(
                rect: introduceRect,
                child: IgnorePointer(
                  child: Padding(
                    padding: widget.padding,
                    child: Align(
                      alignment: alignment,
                      child: widget.introduce,
                    ),
                  ),
                ),
              ),

              // Skip text widget.
              if (widget.skipConfig.enabled)
                Positioned.fill(
                  child: Align(
                    alignment: widget.skipConfig.alignment,
                    child: widget.skip,
                  ),
                ),

              // Next text widget.
              if (widget.nextConfig.enabled)
                Positioned.fill(
                  child: Align(
                    alignment: widget.nextConfig.alignment,
                    child: widget.next,
                  ),
                ),
            ],
          );
  }
}

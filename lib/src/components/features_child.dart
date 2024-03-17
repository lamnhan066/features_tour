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
    required this.done,
    required this.doneConfig,
    required this.isLastState,
    required this.introduce,
    required this.padding,
    this.alignment,
    this.quadrantAlignment,
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

  /// Done button.
  final Widget done;

  /// Done button.
  final DoneConfig doneConfig;

  /// Is this the final steps.
  final bool isLastState;

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
  ///
  /// If this value is `null`, the `top` and `bottom` will be automatically
  /// caculated to get the larger side.
  final QuadrantAlignment? quadrantAlignment;

  @override
  State<FeaturesChild> createState() => _FeaturesChildState();
}

class _FeaturesChildState extends State<FeaturesChild>
    with WidgetsBindingObserver {
  double scale = 1;
  Rect? rect;
  late Rect introduceRect;
  late Alignment alignment;
  QuadrantAlignment? _quadrantAlignment;

  /// Render longside with the transition, such as the Drawer.
  void _autoUpdate() {
    int times = 0;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!_updateState() && times >= 10) {
        timer.cancel();
      }
      times++;
    });
  }

  /// Update the current state.
  bool _updateState() {
    if (!mounted) return false;

    final tempRect = (widget.globalKey).globalPaintBounds;
    if (tempRect != null) {
      if (tempRect == rect) {
        return false;
      }
      rect = tempRect;
    }

    _autoSetQuadrantAlignment(rect!);

    var size = MediaQuery.maybeOf(context)?.size;
    size ??= MediaQueryData.fromView(View.of(context)).size;
    switch (_quadrantAlignment!) {
      case QuadrantAlignment.top:
        introduceRect = Rect.fromLTRB(0, 0, size.width, rect!.top);
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          alignment = switch (_calculateAlignmentHorizontal(rect!, size)) {
            Alignment.centerLeft => Alignment.bottomLeft,
            Alignment.centerRight => Alignment.bottomRight,
            _ => Alignment.bottomCenter,
          };
        }
      case QuadrantAlignment.left:
        introduceRect = Rect.fromLTRB(0, 0, rect!.left, size.height);
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          alignment = switch (_calculateAlignmentVertical(rect!, size)) {
            Alignment.topCenter => Alignment.topRight,
            Alignment.bottomCenter => Alignment.bottomRight,
            _ => Alignment.centerRight,
          };
        }
      case QuadrantAlignment.right:
        introduceRect = Rect.fromLTRB(rect!.right, 0, size.width, size.height);
        alignment = widget.alignment ?? Alignment.centerLeft;
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          alignment = switch (_calculateAlignmentVertical(rect!, size)) {
            Alignment.topCenter => Alignment.topLeft,
            Alignment.bottomCenter => Alignment.bottomLeft,
            _ => Alignment.centerLeft,
          };
        }
      case QuadrantAlignment.bottom:
        introduceRect = Rect.fromLTRB(0, rect!.bottom, size.width, size.height);
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          alignment = switch (_calculateAlignmentHorizontal(rect!, size)) {
            Alignment.centerLeft => Alignment.topLeft,
            Alignment.centerRight => Alignment.topRight,
            _ => Alignment.topCenter,
          };
        }
      case QuadrantAlignment.inside:
        introduceRect = rect!;
        alignment = widget.alignment ?? Alignment.center;
    }

    setState(() {});
    return true;
  }

  /// Find the larger height between the top and bottom rectangle to set the
  /// quadrantAlignment
  void _autoSetQuadrantAlignment(Rect rect) {
    if (_quadrantAlignment != null) return;

    if (widget.quadrantAlignment != null) {
      _quadrantAlignment = widget.quadrantAlignment!;
    } else {
      final size = MediaQuery.of(context).size;
      final topRect = Rect.fromLTRB(0, 0, size.width, rect.top);
      final bottomRect = Rect.fromLTRB(0, rect.bottom, size.width, size.height);
      if (topRect.height > bottomRect.height) {
        _quadrantAlignment = QuadrantAlignment.top;
      } else {
        _quadrantAlignment = QuadrantAlignment.bottom;
      }
    }
  }

  /// Calculate to get the prefer alignment for the `introduce` widget.
  ///
  /// For the `top` and `bottom` quadrant alignment.
  Alignment _calculateAlignmentHorizontal(Rect rect, Size size) {
    if (rect.left > size.width / 2) {
      return Alignment.centerRight;
    } else if (rect.right < size.width / 2) {
      return Alignment.centerLeft;
    }

    return Alignment.center;
  }

  /// Calculate to get the prefer alignment for the `introduce` widget.
  ///
  /// For the `left` and `right` quadrant alignment.
  Alignment _calculateAlignmentVertical(Rect rect, Size size) {
    if (rect.top > size.height / 2) {
      return Alignment.bottomCenter;
    } else if (rect.bottom < size.height / 2) {
      return Alignment.topCenter;
    }

    return Alignment.center;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _autoUpdate();

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
    _updateState();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateState();
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
              if (!(widget.isLastState && widget.doneConfig.enabled) &&
                  widget.skipConfig.enabled)
                Positioned.fill(
                  child: Align(
                    alignment: widget.skipConfig.alignment,
                    child: widget.skip,
                  ),
                ),

              // Next text widget.
              if (!(widget.isLastState && widget.doneConfig.enabled) &&
                  widget.nextConfig.enabled)
                Positioned.fill(
                  child: Align(
                    alignment: widget.nextConfig.alignment,
                    child: widget.next,
                  ),
                ),

              // Done text widget.
              if (widget.isLastState && widget.doneConfig.enabled)
                Positioned.fill(
                  child: Align(
                    alignment: widget.doneConfig.alignment,
                    child: widget.done,
                  ),
                ),
            ],
          );
  }
}

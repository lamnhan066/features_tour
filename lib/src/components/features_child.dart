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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  Rect? rect;
  late Rect introduceRect;
  late Alignment alignment;
  QuadrantAlignment? _quadrantAlignment;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  /// Render longside with the transition, such as the Drawer.
  Future<void> _autoUpdate() async {
    int times = 0;
    while (mounted && times < 10) {
      final updated = _updateState();
      if (!updated && times >= 10) break;
      times++;
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  /// Update the current state.
  bool _updateState() {
    if (!mounted) return false;

    final tempRect = (widget.globalKey).globalPaintBounds;
    if (tempRect != null && tempRect != rect) {
      rect = tempRect;
    }

    if (rect == null) return false;

    _autoSetQuadrantAlignment(rect!);

    var size = MediaQuery.maybeOf(context)?.size ??
        MediaQueryData.fromView(View.of(context)).size;

    switch (_quadrantAlignment!) {
      case QuadrantAlignment.top:
        introduceRect = Rect.fromLTRB(0, 0, size.width, rect!.top);
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          double dialogWidth = size.width.clamp(280, 400);
          double left = rect!.topCenter.dx - dialogWidth / 2;
          if (left < 0) {
            alignment = Alignment.bottomLeft;
            left = 0;
          } else if (left + dialogWidth > size.width) {
            alignment = Alignment.bottomRight;
            left = size.width - dialogWidth;
          } else {
            alignment = Alignment.bottomCenter;
          }
          introduceRect =
              Rect.fromLTWH(left, 0, dialogWidth, introduceRect.height);
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
          double dialogWidth = size.width.clamp(280, 400);
          double left = rect!.topCenter.dx - dialogWidth / 2;
          if (left < 0) {
            alignment = Alignment.topLeft;
            left = 0;
          } else if (left + dialogWidth > size.width) {
            alignment = Alignment.topRight;
            left = size.width - dialogWidth;
          } else {
            alignment = Alignment.topCenter;
          }
          introduceRect =
              Rect.fromLTWH(left, introduceRect.top, dialogWidth, size.height);
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

    _scaleController = AnimationController(
      vsync: this,
      duration: widget.childConfig.animationDuration,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: widget.childConfig.zoomScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: widget.childConfig.curve,
    ));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _autoUpdate();
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
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateState();
    super.didChangeMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.brightnessOf(context);

    return rect == null
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              // Border widget
              Positioned.fromRect(
                rect: rect!.inflate(widget.childConfig.borderSizeInflate),
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Material(
                        color: widget.childConfig.backgroundColor,
                        shape: widget.childConfig.shapeBorder,
                      ),
                    );
                  },
                ),
              ),

              // Child widget.
              if (widget.childConfig.isAnimateChild)
                Positioned.fromRect(
                  rect: rect!,
                  child: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: widget.child,
                      );
                    },
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
                      child: DefaultTextStyle(
                        style: TextStyle(
                          color: brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                        child: widget.introduce,
                      ),
                    ),
                  ),
                ),
              ),

              Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [
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
                ),
              ),
            ],
          );
  }
}

import 'package:features_tour/features_tour.dart';
import 'package:features_tour/src/extensions/get_widget_position.dart';
import 'package:flutter/material.dart';

/// An internal widget that displays all the necessary widgets in a Stack.
class FeaturesChild extends StatefulWidget {
  /// An internal widget that displays all the necessary widgets in a Stack.
  const FeaturesChild({
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
    required this.introduceConfig,
    required this.padding,
    super.key,
    this.alignment,
    this.quadrantAlignment,
  });

  /// A `GlobalKey()` to control this widget.
  final GlobalKey globalKey;

  /// The child widget.
  final Widget child;

  /// The child's configuration.
  final ChildConfig childConfig;

  /// The skip button widget.
  final Widget skip;

  /// Skips all the steps.
  final SkipConfig skipConfig;

  /// The next button widget.
  final Widget next;

  /// Moves to the next step.
  final NextConfig nextConfig;

  /// The done button.
  final Widget done;

  /// The done button's configuration.
  final DoneConfig doneConfig;

  /// Indicates if this is the final step.
  final bool isLastState;

  /// The feature introduction widget, typically a `Text` widget.
  final Widget introduce;

  /// The introduction widget's configuration.
  final IntroduceConfig introduceConfig;

  /// The padding of the `introduce` widget.
  final EdgeInsetsGeometry padding;

  /// The alignment of the `introduce` widget inside the `quadrantAlignment`.
  ///
  /// This value automatically aligns depending on the `quadrantAlignment`.
  /// It is positioned as close as possible to other elements.
  final Alignment? alignment;

  /// The quadrant rectangle for the `introduce` widget.
  ///
  /// If this value is `null`, the `top` and `bottom` will be automatically
  /// calculated to get the larger side.
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

  /// Continuously updates the rect while the widget is mounted.
  /// It stops automatically when disposed.
  void _autoUpdate() {
    var times = 0;
    void frameCallback(Duration _) {
      if (!mounted) return;

      final updated = _updateState();
      if (!updated && times >= 10) return;
      times++;

      // Keeps listening for every frame while mounted.
      WidgetsBinding.instance.addPostFrameCallback(frameCallback);
    }

    // Starts listening.
    WidgetsBinding.instance.addPostFrameCallback(frameCallback);
  }

  /// Updates the current state.
  bool _updateState() {
    if (!mounted || widget.globalKey.currentContext?.mounted != true) {
      return false;
    }

    final tempRect = widget.globalKey.globalPaintBounds;
    if (tempRect != null) {
      if (tempRect == rect) {
        return false;
      }

      rect = tempRect;
    }

    if (rect == null) return false;

    _autoSetQuadrantAlignment(rect!);

    final size =
        MediaQuery.maybeOf(context)?.size ??
        MediaQueryData.fromView(View.of(context)).size;

    switch (_quadrantAlignment!) {
      case QuadrantAlignment.top:
        introduceRect = Rect.fromLTRB(0, 0, size.width, rect!.top);
        if (widget.alignment != null) {
          alignment = widget.alignment!;
        } else {
          final dialogWidth = size.width.clamp(280, 400).toDouble();
          var left = rect!.topCenter.dx - dialogWidth / 2;
          if (left < 0) {
            alignment = Alignment.bottomLeft;
            left = 0;
          } else if (left + dialogWidth > size.width) {
            alignment = Alignment.bottomRight;
            left = size.width - dialogWidth;
          } else {
            alignment = Alignment.bottomCenter;
          }
          introduceRect = Rect.fromLTWH(
            left,
            0,
            dialogWidth,
            introduceRect.height,
          );
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
          final dialogWidth = size.width.clamp(280, 400).toDouble();
          var left = rect!.topCenter.dx - dialogWidth / 2;
          if (left < 0) {
            alignment = Alignment.topLeft;
            left = 0;
          } else if (left + dialogWidth > size.width) {
            alignment = Alignment.topRight;
            left = size.width - dialogWidth;
          } else {
            alignment = Alignment.topCenter;
          }
          introduceRect = Rect.fromLTWH(
            left,
            introduceRect.top,
            dialogWidth,
            size.height,
          );
        }
      case QuadrantAlignment.inside:
        introduceRect = rect!;
        alignment = widget.alignment ?? Alignment.center;
    }

    setState(() {});
    return true;
  }

  /// Finds the larger height between the top and bottom rectangles to set the
  /// quadrantAlignment.
  void _autoSetQuadrantAlignment(Rect rect) {
    if (_quadrantAlignment != null) return;

    if (widget.quadrantAlignment != null) {
      _quadrantAlignment = widget.quadrantAlignment;
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

  /// Calculates the preferred alignment for the `introduce` widget.
  ///
  /// This is for the `left` and `right` quadrant alignments.
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
    );

    _scaleAnimation = Tween<double>(
      begin: widget.childConfig.zoomScale,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: widget.childConfig.curve,
      ),
    );

    if (widget.childConfig.enableAnimation) {
      _scaleController.repeat(reverse: true).ignore();
    } else {
      _scaleController.value = 1;
      _scaleController.stop();
    }

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
            if (widget.childConfig.enableAnimation &&
                widget.childConfig.isAnimateChild)
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
              Positioned.fromRect(rect: rect!, child: widget.child),

            // Introduction widget.
            Positioned.fromRect(
              rect: introduceRect,
              child: IgnorePointer(
                child: Padding(
                  padding: widget.padding,
                  child: Align(
                    alignment: alignment,
                    child: widget.introduceConfig.builder(
                      context,
                      rect!,
                      widget.introduce,
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

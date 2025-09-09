// https://stackoverflow.com/questions/50316219/how-to-get-widgets-absolute-coordinates-on-a-screen-in-flutter
import 'package:flutter/material.dart';

/// An extension on [GlobalKey] to get the global position of a widget.
extension GlobalKeyExtension on GlobalKey {
  /// Gets the global paint bounds.
  ///
  /// Source: https://stackoverflow.com/a/71568630/16589995
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final matrix = renderObject?.getTransformTo(null);
    if (matrix != null && renderObject?.paintBounds != null) {
      final rect = MatrixUtils.transformRect(matrix, renderObject!.paintBounds);
      return rect;
    } else {
      return null;
    }
  }
}

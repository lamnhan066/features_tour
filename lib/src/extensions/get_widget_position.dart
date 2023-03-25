// https://stackoverflow.com/questions/50316219/how-to-get-widgets-absolute-coordinates-on-a-screen-in-flutter
import 'package:flutter/material.dart';

extension GlobalKeyExtension on GlobalKey {
  /// Get global paint bounds
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

  // Rect? get getRectFromKey {
  //   var object = currentContext?.findRenderObject();
  //   var translation = object?.getTransformTo(null).getTranslation();
  //   var size = object?.semanticBounds.size;

  //   if (translation != null && size != null) {
  //     return Rect.fromLTWH(
  //         translation.x, translation.y, size.width, size.height);
  //   } else {
  //     return null;
  //   }
  // }
}

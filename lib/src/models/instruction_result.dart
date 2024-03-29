/// Result of the `introduce` method.
///
/// [disabled] will be returned when current widget is disabled.
///
/// [notMounted] when the widget is not mounted.
///
/// [skip] when the skip button is pressed.
///
/// [next] when the next button is pressed.
enum IntroduceResult {
  /// [disabled] will be returned when current widget is disabled.
  disabled,

  /// [notMounted] when the widget is not mounted.
  notMounted,

  /// [skip] when the skip button is pressed.
  skip,

  /// [next] when the next button is pressed.
  next,

  /// [done] when the done button is pressed.
  done;
}

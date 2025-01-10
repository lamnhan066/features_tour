/// Result of the `introduce` method.
///
/// [disabled] is returned when the current widget is disabled.
///
/// [notMounted] is returned when the widget is not mounted.
///
/// [skip] is returned when the skip button is pressed.
///
/// [next] is returned when the next button is pressed.
///
/// [done] is returned when the done button is pressed.
enum IntroduceResult {
  /// [disabled] is returned when the current widget is disabled.
  disabled,

  /// [notMounted] is returned when the widget is not mounted.
  notMounted,

  /// [skip] is returned when the skip button is pressed.
  skip,

  /// [next] is returned when the next button is pressed.
  next,

  /// [done] is returned when the done button is pressed.
  done;
}

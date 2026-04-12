/// The result of the `introduce` method.
enum IntroduceResult {
  /// [disabled] is returned when the current widget is disabled.
  disabled,

  /// [notMounted] is returned when the widget is not mounted.
  notMounted,

  /// [skip] is returned when the skip button is pressed.
  skip,

  /// [previous] is returned when the previous button is pressed.
  previous,

  /// [next] is returned when the next button is pressed.
  next,

  /// [done] is returned when the done button is pressed.
  done,
}

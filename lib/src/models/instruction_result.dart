/// Result of the `introduce` method.
///
/// [disabled] will be returned when current widget is disabled
/// [notMounted] when the widget is not mounted
/// [wrongState] when the widget is in wrong state
/// [skip] when the skip button is pressed
/// [next] when the next button is pressed
enum IntroduceResult {
  disabled,
  notMounted,
  wrongState,
  skip,
  next;
}

/// Result of the `introdure` method.
///
/// [disabled] will be returned when current widget is disabled
/// [notMounted] when the widget is not mounted
/// [wrongState] when the widget is in wrong state
/// [skip] when the skip button is pressed
/// [next] when the next button is pressed
enum IntrodureResult {
  disabled,
  notMounted,
  wrongState,
  skip,
  next;
}

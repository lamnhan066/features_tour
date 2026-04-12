/// A result returned by a tour instruction, indicating the action taken during the tour.
@Deprecated('Use TourAction instead of IntroduceResult')
typedef IntroduceResult = TourAction;

/// The action taken during the tour.
enum TourAction {
  /// The introduction is about to be shown.
  introduce,

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

import 'package:features_tour/features_tour.dart';

/// The base class for all states of the feature tour.
sealed class TourState {
  /// Creates a new instance of [TourState].
  const TourState();
}

/// Indicates that the feature tour is currently in progress.
class TourInProgress extends TourState {
  /// Creates a new instance of [TourInProgress].
  const TourInProgress();
}

/// Indicates that the feature tour is not currently mounted in the widget tree.
class TourNotMounted extends TourState {
  /// Creates a new instance of [TourNotMounted].
  const TourNotMounted();
}

/// Indicates that there are no feature tour states to be shown.
class TourEmptyStates extends TourState {
  /// Creates a new instance of [TourEmptyStates].
  const TourEmptyStates();
}

/// Indicates that the user has dismissed all feature tours.
class TourAllTourDismissedByUser extends TourState {
  /// Creates a new instance of [TourAllTourDismissedByUser].
  const TourAllTourDismissedByUser();
}

/// Indicates that the pre-dialog for the feature tour is not shown.
class TourPreDialogNotShown extends TourState {
  /// Creates a new instance of [TourPreDialogNotShown].
  const TourPreDialogNotShown();
}

/// Indicates that the pre-dialog for the feature tour is not shown because
/// the user has applied the choice to all pages.
class TourPreDialogShownByAppliedToAllPages extends TourState {
  /// Creates a new instance of [TourPreDialogShownByAppliedToAllPages].
  const TourPreDialogShownByAppliedToAllPages(this.buttonType);

  /// The type of button that triggered the state change.
  final PredialogButtonType buttonType;
}

/// Indicates that the pre-dialog for the feature tour is currently being shown.
class TourPreDialogIsShown extends TourState {
  /// Creates a new instance of [TourPreDialogIsShown].
  const TourPreDialogIsShown();
}

/// Indicates that a custom pre-dialog for the feature tour is currently being shown.
class TourPreDialogIsShownWithCustomDialog extends TourState {
  /// Creates a new instance of [TourPreDialogIsShownWithCustomDialog].
  const TourPreDialogIsShownWithCustomDialog();
}

/// Indicates that the "Apply to all pages" checkbox state has changed.
class TourPreDialogApplyToAllPagesCheckboxChanged extends TourState {
  /// Creates a new instance of [TourPreDialogApplyToAllPagesCheckboxChanged].
  const TourPreDialogApplyToAllPagesCheckboxChanged(this.isChecked);

  /// Indicates whether the checkbox is checked or not.
  final bool isChecked;
}

/// Indicates that a button in the pre-dialog has been pressed.
class TourPreDialogButtonPressed extends TourState {
  /// Creates a new instance of [TourPreDialogButtonPressed].
  const TourPreDialogButtonPressed(this.buttonType);

  /// The type of button that was pressed.
  final PredialogButtonType buttonType;
}

/// Indicates that a specific feature is currently being introduced.
class TourIntroducing extends TourState {
  /// Creates a new instance of [TourIntroducing].
  const TourIntroducing({required this.index});

  /// The index of the feature being introduced.
  final double? index;
}

/// Indicates that the introduction for a specific feature should not be shown.
class TourShouldNotShowIntroduction extends TourState {
  /// Creates a new instance of [TourShouldNotShowIntroduction].
  const TourShouldNotShowIntroduction({required this.index});

  /// The index of the feature that should not be shown.
  final double? index;
}

/// Indicates that the `introduce` method has been called, but the introduction has not yet started.
class TourBeforeIntroduceCalled extends TourState {
  /// Creates a new instance of [TourBeforeIntroduceCalled].
  const TourBeforeIntroduceCalled();
}

/// Indicates that the `introduce` method has been called, and the introduction has finished.
class TourAfterIntroduceCalled extends TourState {
  /// Creates a new instance of [TourAfterIntroduceCalled].
  const TourAfterIntroduceCalled();
}

/// Indicates that an introduction has been completed, and a result has been emitted.
class TourIntroduceResultEmitted extends TourState {
  /// Creates a new instance of [TourIntroduceResultEmitted].
  const TourIntroduceResultEmitted({required this.result});

  /// The result of the introduction.
  final IntroduceResult result;
}

/// Indicates that the feature tour has been completed.
class TourCompleted extends TourState {
  /// Creates a new instance of [TourCompleted].
  const TourCompleted();
}

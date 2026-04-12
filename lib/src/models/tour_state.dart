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
class TourEmpty extends TourState {
  /// Creates a new instance of [TourEmpty].
  const TourEmpty();
}

/// Indicates that the user has dismissed all feature tours.
class TourDismissedAllByUser extends TourState {
  /// Creates a new instance of [TourDismissedAllByUser].
  const TourDismissedAllByUser();
}

/// Indicates that the pre-dialog for the feature tour is not shown.
class TourPreDialogHidden extends TourState {
  /// Creates a new instance of [TourPreDialogHidden].
  const TourPreDialogHidden();
}

/// Indicates that the pre-dialog for the feature tour is not shown because
/// the user has applied the choice to all pages.
class TourPreDialogHiddenByAppliedToAll extends TourState {
  /// Creates a new instance of [TourPreDialogHiddenByAppliedToAll].
  const TourPreDialogHiddenByAppliedToAll(this.buttonType);

  /// The type of button that triggered the state change.
  final PreDialogButtonType buttonType;
}

/// Indicates that the pre-dialog for the feature tour is currently being shown.
class TourPreDialogShownDefault extends TourState {
  /// Creates a new instance of [TourPreDialogShownDefault].
  const TourPreDialogShownDefault();
}

/// Indicates that a custom pre-dialog for the feature tour is currently being shown.
class TourPreDialogShownCustom extends TourState {
  /// Creates a new instance of [TourPreDialogShownCustom].
  const TourPreDialogShownCustom();
}

/// Indicates that the "Apply to all pages" checkbox state has changed.
class TourPreDialogApplyToAllChanged extends TourState {
  /// Creates a new instance of [TourPreDialogApplyToAllChanged].
  const TourPreDialogApplyToAllChanged(this.isChecked);

  /// Indicates whether the checkbox is checked or not.
  final bool isChecked;
}

/// Indicates that a button in the pre-dialog has been pressed.
class TourPreDialogButtonPressed extends TourState {
  /// Creates a new instance of [TourPreDialogButtonPressed].
  const TourPreDialogButtonPressed(this.buttonType);

  /// The type of button that was pressed.
  final PreDialogButtonType buttonType;
}

/// Indicates that a specific feature is currently being introduced.
class TourIntroducing extends TourState {
  /// Creates a new instance of [TourIntroducing].
  const TourIntroducing({required this.index});

  /// The index of the feature being introduced.
  final double? index;
}

/// Indicates that the introduction for a specific feature should not be shown.
class TourSkippedIntroduction extends TourState {
  /// Creates a new instance of [TourSkippedIntroduction].
  const TourSkippedIntroduction({required this.index});

  /// The index of the feature that should not be shown.
  final double? index;
}

@Deprecated('Use TourBeforeActionCalled instead of TourBeforeIntroduceCalled')
/// Indicates that the `introduce` method has been called, but the introduction has not yet started.
typedef TourBeforeIntroduceCalled = TourBeforeActionCalled;

/// Indicates that the `introduce` method has been called, but the introduction has not yet started.
class TourBeforeActionCalled extends TourState {
  /// Creates a new instance of [TourBeforeActionCalled].
  const TourBeforeActionCalled();
}

@Deprecated('Use TourAfterActionCalled instead of TourAfterIntroduceCalled')
/// Indicates that the `introduce` method has been called, and the introduction has finished.
typedef TourAfterIntroduceCalled = TourAfterActionCalled;

/// Indicates that the `introduce` method has been called, and the introduction has finished.
class TourAfterActionCalled extends TourState {
  /// Creates a new instance of [TourAfterActionCalled].
  const TourAfterActionCalled();
}

/// Indicates that an introduction has been completed, and an action has been emitted.
class TourActionEmitted extends TourState {
  /// Creates a new instance of [TourActionEmitted].
  const TourActionEmitted({required this.result});

  /// The action emitted by the introduction.
  final TourAction result;
}

/// Indicates that the feature tour has been completed.
class TourCompleted extends TourState {
  /// Creates a new instance of [TourCompleted].
  const TourCompleted();
}

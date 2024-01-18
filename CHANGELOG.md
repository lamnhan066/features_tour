## 0.3.0-rc.1

* Fixes issue that the `rect` accept the `null` value causes infinity loading.

## 0.3.0-rc

* Bump Dart min sdk to 3.0.0.
* The parameter `child` inside the `ChildConfig` is now passed with the "real" child, so we can easily modify the child widget.

  * Before:

  ```dart
  ChildConfig.copyWith(
    child: YourFakeChildWidget(),
  ),
  ```

  * Now:

  ```dart
  ChildConfig.copyWith(
    child: (child) {
      return YourFakeWidget(
        child: child,
      );
    },
  ),
  ```

* The `Next` button and `Skip` button are changed to `ElevatedButton` by default.
* The `Next` button text is changed to `NEXT` and `Skip` button text is changed to `SKIP`.
* The `NextConfig` and `SkipConfig` button have a `child` parameter to create your own button.
* The `introduce` alignment is automaticaly calculated denpens on the position of the `child` widget.

## 0.2.2

* Add `dismissible` parameter to `ChildConfig`, so users can tap anywhere to move to the next introduce (can be a replacement for the Next button).
* Update dependencies.

## 0.2.1

* Update comments.
* Update homepage URL.

## 0.2.0

* Add `waitForFirstIndex` and `waitForFirstTimeout` to `FeaturesTourController`.
* Pre-Dialog:
  * Add `dismiss` button to dismiss the current page, the tour will not shows again even when a new one is added.
  * Add `acceptButtonStyle`, `laterButtonStyle` and `dismissButtonStyle`.
  * Change button text type from `String` to `Text`.
* Improve README.

## 0.1.4

* **[BREAKING CHANGE BUG]** Not completely renamed from `yesButtonText` and `noButtonText` to `acceptButtonText` and `cancelButtonText` in the `PredialogConfig`.
* [BUG] `SkipButton` get a wrong text color from `NextButton`.

## 0.1.3

* Add border to the Skip and Next button by default (with color of text color).
* Add `textStyle` and `buttonStyle` parameters to `SkipConfig` and `NextConfig` to modify the Next and Skip button style.

## 0.1.2

* Rename `doNotAskAgainText` to `applyToAllPagesText` in `PredialogConfig` to make it easier to understand. Also changed from `Do not ask again this time` to `Apply to all pages`.
* Resize the predialog text and checkbox.
* Using sdk: ">=2.18.0 <4.0.0" and flutter: ">=3.3.0".
* Add `debugLog` parameter to `setGlobalConfig` to allow disabling the debug logs.

## 0.0.5+3

* Update dependencies.
* Improve pub score.

## 0.0.5+2

* Improve pub score.

## 0.0.5

* Add `waitForIndex` and `waitForTimeout` to able to wait for a next specific index. The screen will be freesed when waiting for the next index.
* The tours is now respect the `force` parameter correctly:
  * `null` (default): only show when needed.
  * `true`: force to show all the tours, including pre-dialogs.
  * `false`: force to not show all the tours and pre-dialogs.
* Add example for the new parameters.

## 0.0.4

* Allow using your own pre-dialog by using `modifiedDialogResult` parameter in `PredialogConfig`.
* Slightly reduce the default pre-dialog content bottom padding.
* Update README.

## 0.0.3

* `onPressed` is now can use as `Future` method. The next widget of the tour will be only called when this Future is completed.
* The tours now will sort the new added states (some states need time to appear).
* Add `isAnimateChild` and `borderSizeInflate` to ChildConfig:
  * `isAnimateChild` is allow it to be animated along with the border.
  * `borderSizeInflate` is alow to set it to be bigger than the child widget. So the border widget is now bigger than the child widget 3 delta.
* Add `isCallOnPressed` to ChildConfig to allow the `onPressed` method to be called when user presses the Skip button.
* Avoid `onPressed` is called multiple times when it needs time to be completed.

## 0.0.2

* Improves loading and update behavior.

## 0.0.1

* Initial release.

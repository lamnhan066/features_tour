## 0.4.14

* **Features**:
  * Automatically adapts to the app's dark/light theme.
  * Waits for the drawer animation to finish before proceeding.
  * Introduced `onBeforeIntroduce` and `onAfterIntroduce` parameters for enhanced control.

* **Fixes**:
  * Resolved the issue where `waitForIndex` would still activate even after users tapped the `SKIP` button.

* **Deprecations**:
  * Deprecated the `onPressed` parameter in `FeaturesTour` in favor of `onAfterIntroduce`.
  * Deprecated the `isCallOnPressed` parameter in `SkipConfig` in favor of `onAfterIntroduce(IntroduceResult)`.

* **Updates**:
  * Enhanced the example for better clarity.
  * Updated the README to reflect the latest changes.

## 0.4.13

* Add `debugLog` parameter to the `tourController.start` method to enable or disable debug logging.
* Prevent screen flashing during the transition between two `FeaturesTour` instances by maintaining the background color.
* Fix the issue that makes the buttons (`Next`, `Skip` and `Done`) appear under the keyboard.
* Update the introduction video.

## 0.4.12

* Add `canPop` parameter to the `FeaturesTour` to control the `PopScope`.
* Add `applyToAllPagesTextColor` parameter to PredialogConfig to set the color for the `Apply to all pages` text.
* Improve the style of the pre-dialog checkbox and label.

## 0.4.11

* `FeaturesTour` is now a `const`.
* It's safe to wrap `FeaturesTour`s with a `FeaturesTour` (It had the duplicated `GlobalKey` issue before).
* Add `onAcceptButtonPressed`, `onLaterButtonPressed` and `onDismissButtonPressed` to the `Predialog` to handle those button pressed callbacks.
* Refactor internal code.

## 0.4.10

* [Feat] Add an ability to show on top of all Overlays.
* [Refactor] Improve comments.

## 0.4.9

* Fixed the issue that make the package keeps introduce a widget even when `waitForTimeout` is reached.

## 0.4.8

* Fixed the issue that the tours run incorrectly when `force` is set to `true`.

## 0.4.7

* Add the `enableAnimation` to the `ChildConfig` to make it easier to enable/disable the animation.
* Update the topics.

## 0.4.6+1

* Improve the pub score.
* Small update for the example.

## 0.4.6

* The `shapeBorder` of the `ChildConfig` now works correctly.
* Auto apply the dark theme to the `introduce` widget with the `applyDarkTheme` parameter in the `IntroduceConfig`.
* Add a border to the outter child widget.

## 0.4.5

* Replace the `showDialog` with the `Overlay` to avoid hiding the keyboard.

## 0.4.4

* Rename and mark the old one as deprecated:
  * `PredialogConfig.copyWith` to `PredialogConfig`.
  * `ChildConfig.copyWith` to `ChildConfig`.
  * `IntroduceConfig.copyWith` to `IntroduceConfig`.
  * `NextConfig.copyWith` to `NextConfig`.
  * `SkipConfig.copyWith` to `SkipConfig`.
  * `DoneConfig.copyWith` to `DoneConfig`.
* Improve the way to print the debug log.
* Fix some TYPO.

## 0.4.3

* Fixed an issue caused `barrierDismissible` in the ChildConfig doesn't work properly.

## 0.4.2

* Avoid text overflowing for the `applyToAllPagesText` in the pre-dialog by using `FittedBox`.

## 0.4.1+2

* Update example.
* Add a demo website using the example on README.

## 0.4.1+1

* Fix:  README typo. (Thanks @ashwinkey04)

## 0.4.1

* The Done button doesn't show correctly when it's called by a `waitForIndex` introduction.
* Automatically calculate the position of the introduce widget in QuadrantAlignment.top and bottom, so the `introduce` widget is always at the top/bottom center comparing to its `child`.
* Update example.

## 0.4.0

* Change to BSD 3-Clause License.
* Release to stable.

## 0.4.0-rc.2

* Improves the Done button behavior when there is a new FeaturesTour is added.

## 0.4.0-rc.1

* Add `Done` button to show on the last introduction (`Next` and `Skip` button will be hidden).
* `index` in `FeaturesTour` is required since this version.

## 0.3.1

* Fixes issue that the last state is not removed.

## 0.3.0

* Release to stable.

## 0.3.0-rc.6

* Fix an issue related to `enabled` parameter.

## 0.3.0-rc.5

* Caches the GlobalKey better.

## 0.3.0-rc.4

* Avoid creating unnecessary new GlobalKey that causes issues (needs double taps to trigger a function).
* Avoid duplicating an introduction.

## 0.3.0-rc.3

* Only add `GlobalKey` to the enabled `FeaturesTour`.

## 0.3.0-rc.2

* Move `waitForFirstIndex` and `waitForFirstTimeout` from `FeaturesTourController` to `start` method.
* Change the `context` parameter in the `start` method from named to positioned parameter.
* Change to use `StatelessWidget` for `FeaturesTour`.
* Ignore the unmounted Widget correctly.
* Able to adapt with the transition of the Widget like the Drawer.
* Add an effective way to control the list of states to avoid the duplicated state issue.
* Migration:
  * Before:

  ```dart
  final tourController = FeaturesTourController(
    'Page', 
    waitForFirstIndex: 1.0,
    waitForFirstTimeout: const Duration(seconds: 4),
  );

  tourController.start(context: context);
  ```

  * Now:

  ```dart
  final tourController = FeaturesTourController('Page');

  tourController.start(
    context,
    waitForFirstIndex: 1.0,
    waitForFirstTimeout: const Duration(seconds: 3),
  );
  ```  

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

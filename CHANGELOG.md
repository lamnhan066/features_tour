## 0.0.3

* `onPressed` is now can use as `Future` method. The next widget of the tour will be only called when this Future is completed.
* The tours now will sort the new added states (some states need time to appear).
* Add `isAnimateChild` and `borderSizeInflate` to ChildConfig:
  * `isAnimateChild` is allow it to be animated along with the border.
  * `borderSizeInflate` is alow to set it to be bigger than the child widget.
* Add `isCallOnPressed` to ChildConfig to allow the `onPressed` method to be called when user presses the Skip button.
* Avoid `onPressed` is called multiple times when it needs time to be completed.

## 0.0.2

* Improves loading and update behavior.

## 0.0.1

* Initial release.

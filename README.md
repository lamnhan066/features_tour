# Features Tour

[![codecov](https://codecov.io/gh/lamnhan066/features_tour/graph/badge.svg?token=1RTE5RXFIR)](https://codecov.io/gh/lamnhan066/features_tour)

Features Tour is a package that enables you to easily create tours to introduce your widget features in your app with order. It provides a straightforward and flexible API that allows you to customize the look and feel of the tour to match your app's design.

## Introduction

Demo: [pub.lamnhan.dev/features\_tour](https://pub.lamnhan.dev/features_tour)

## Quick Start

### Create a controller

```dart
final tourController = FeaturesTourController('HomePage');
```

Use a stable page name. The controller persists tour progress by page, so changing the name will make the tour look new again.

### Wrap a feature

Prefer enum-based steps. The enum declaration order becomes the tour order, and the step name becomes the cache key.

```dart
enum HomeTourStep {
    drawer,
    drawerButton,
    settings,
    list,
    firstItem,
    lastItem,
    dialogButton,
    restart,
    addButton,
}

FeaturesTour(
    controller: tourController,
    step: HomeTourStep.drawer,
    nextStep: HomeTourStep.drawerButton,
    introduce: const Text('Tap here to open the drawer'),
    onAfterAction: (action) {
        if (action case TourAction.next || TourAction.done) {
            scaffoldKey.currentState?.openDrawer();
        }
    },
    child: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
    ),
)
```

Use `onBeforeAction` to prepare the current surface, for example by scrolling a widget into view. Use `onAfterAction` when the current step should open a drawer, dialog, or another surface before the next step appears.

### Start the tour

```dart
@override
void initState() {
    super.initState();
    tourController.start(
        context,
        firstStep: HomeTourStep.drawer,
        firstStepTimeout: const Duration(seconds: 3),
    );
}
```

`firstStep` is the preferred entry point. The controller still accepts `firstIndex` and `firstIndexTimeout` for migration, but new code should use the enum-based API.

## Global Configuration

Set global defaults in `main()` before the app renders. The example app uses custom dialog labels, custom buttons, rounded introduce styling, and disabled child animation:

```dart
void main() {
    FeaturesTour.setGlobalConfig(
        preDialogConfig: PreDialogConfig(
            enabled: true,
            title: 'Welcome to Features Tour',
            content: 'This tour will guide you through the main features of the app.',
            applyToAllCheckboxLabel: 'Apply to all pages',
            acceptButtonLabel: 'Start Tour',
            laterButtonLabel: 'Later',
            dismissButtonLabel: 'Dismiss',
        ),
        introduceConfig: RoundedRectIntroduceConfig(),
        childConfig: ChildConfig(isAnimateChild: false),
        skipConfig: SkipConfig(
            builder: (context, onPressed) => ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.skip_next),
                label: const Text('SKIP'),
            ),
        ),
        nextConfig: NextConfig(
            builder: (context, onPressed) => FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('NEXT'),
            ),
        ),
        previousConfig: PreviousConfig(
            builder: (context, onPressed) => FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.arrow_back),
                label: const Text('PREVIOUS'),
            ),
        ),
        doneConfig: DoneConfig(
            builder: (context, onPressed) => FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.done),
                label: const Text('DONE'),
            ),
        ),
        debugLog: true,
    );

    runApp(const ChangeableThemeMaterialApp());
}
```

Use `ChildConfig` for the highlighted area, `IntroduceConfig` for the callout, and the button configs for custom navigation affordances. `PreDialogConfig` controls the pre-tour confirmation dialog, including the optional apply-to-all-pages behavior.

## Flow and Callbacks

`TourAction` describes the user action that reached or ended a step: `introduce`, `next`, `previous`, `done`, `skip`, `disabled`, and `notMounted`.

`onBeforeAction` runs before the step is introduced. The widget must already be mounted when this hook runs, so use it only for visible preparation like scrolling a list into view or reopening a surface that is already part of the widget tree. Do not use it to open a dialog for the current widget; trigger that from the previous step's `onAfterAction` instead. The first appearance of a step receives `TourAction.introduce`; returning to it from the next step receives `TourAction.previous`.

`onAfterAction` runs after the user chooses a navigation action from the current step. This is where the example app opens the drawer for the next surface, closes the drawer when going back, or opens a dialog after the last list item.

`onStateChanged` lets you observe the tour lifecycle. Common states include `TourInProgress`, `TourIntroducing`, `TourPreDialogShownDefault`, `TourPreDialogShownCustom`, `TourCompleted`, and `TourEmpty`.

```dart
tourController.start(
    context,
    onStateChanged: (state) {
        switch (state) {
            case TourIntroducing(step: final step):
                debugPrint('Introducing: $step');
            case TourCompleted():
                debugPrint('Tour finished');
            default:
                break;
        }
    },
);
```

## Advanced Flows

### Drawer and dialog tours

Open the target surface from the previous step and let `nextStep` wait for the new widget to appear. This is the pattern used in the example app and in the drawer/dialog tests.

```dart
FeaturesTour(
    controller: tourController,
    step: HomeTourStep.drawerButton,
    nextStep: HomeTourStep.settings,
    onAfterAction: (action) {
        if (action case TourAction.next || TourAction.done) {
            scaffoldKey.currentState?.openDrawer();
        }
    },
    child: ElevatedButton(
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
        child: const Text('Open drawer'),
    ),
)
```

For dialogs, open the dialog from the prior step, then use a `FeaturesTour` inside the dialog content for the dialog-specific step.

### Scroll-driven steps

Use `onBeforeAction` to scroll the current item into view before the introduction starts or when the user returns from the next step. The widget must already be mounted when this callback runs, so it is not a good place to open a dialog for the current step.

```dart
FeaturesTour(
    controller: tourController,
    step: HomeTourStep.lastItem,
    onBeforeAction: (action) async {
        if (action case TourAction.next || TourAction.previous) {
            await scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
            );
        }
    },
    child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Item 90'),
    ),
)
```

### Conditional steps in lists

When multiple list items share the same `step`, set `enabled: true` on the one item that should participate in the tour and `enabled: false` on the rest.

### Bottom edge padding

Use `FeaturesTourPadding` to keep navigation buttons from overlapping bottom-aligned widgets. Prefer `steps` for enum-based tours.

```dart
FeaturesTourPadding(
    controller: tourController,
    steps: const {
        HomeTourStep.restart,
        HomeTourStep.addButton,
    },
)
```

`indexes` is still supported for migration, but `steps` is the preferred API.

## Customization Notes

`IntroduceConfig` can be customized with a builder, barrier color builder, padding, quadrant alignment, alignment, and root overlay support. `RoundedRectIntroduceConfig()` is the preset to use when you want a rounded callout with better contrast out of the box.

`ChildConfig` supports a custom wrapper builder, background color, shape border, animation settings, zoom scale, and border inflation around the highlighted child.

`PreDialogConfig` supports custom labels, button styles, callbacks, and a `customDialogBuilder` if you want to replace the default dialog entirely.

## Migration Notes

- Prefer `step` over `index`.
- Prefer `nextStep` and `nextStepTimeout` over `nextIndex` and `nextIndexTimeout`.
- Prefer `FeaturesTourPadding.steps` over `FeaturesTourPadding.indexes`.
- Prefer `onBeforeAction` and `onAfterAction` over the deprecated `onBeforeIntroduce` and `onAfterIntroduce` callbacks.
- Prefer `onBeforeAction` and `onAfterAction` over the deprecated `onBeforeIntroduce` and `onAfterIntroduce` callbacks.

- Prefer `onStateChanged` over the deprecated `onState` callback. The older `onState` parameter is still supported for migration but will be removed in a future release.

## Reference Examples

- [example/lib/main.dart](example/lib/main.dart) shows the full app setup, including global config, drawers, dialogs, scrolling, and bottom padding.
- [test/step_api_test.dart](test/step_api_test.dart) covers enum-based step ordering and caching.
- [test/drawer_dialog_action_test.dart](test/drawer_dialog_action_test.dart) covers drawer and dialog transitions.
- [test/introduce_config_test.dart](test/introduce_config_test.dart) covers introduce customization.
- [test/main_test.dart](test/main_test.dart) covers controller lifecycle and state reporting.

## Contributions

Contributions to this project are welcome. Open an issue or submit a pull request if you find a bug or want to improve the package.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<p align='center'><a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=lamnhan066&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" width="200"></a></p>

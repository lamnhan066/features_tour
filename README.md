# Features Tour

[![codecov](https://codecov.io/gh/lamnhan066/features_tour/graph/badge.svg?token=1RTE5RXFIR)](https://codecov.io/gh/lamnhan066/features_tour)

Features Tour is a package that enables you to easily create tours to introduce your widget features in your app with order. It provides a straightforward and flexible API that allows you to customize the look and feel of the tour to match your app's design.

## Introduction

Demo: [pub.lamnhan.dev/features\_tour](https://pub.lamnhan.dev/features_tour)

## Usage

### Create a controller

```dart
// Use this method to set the unique name for the current page.
final tourController = FeaturesTourController('HomePage');
```

### Create a tour widget

```dart
enum TourStep { buttonOnDialog, button, drawer, details, buttonOnDrawer }

FeaturesTour(
    controller: tourController,
    step: TourStep.drawer,
    nextStep: TourStep.details,
    nextStepTimeout: const Duration(seconds: 3),
    previousStepTimeout: const Duration(seconds: 3),
    introduce: const Text('This is TextButton 1'),
    onBeforeAction: (action) async {
        if (action == TourAction.introduce) {
            // Do something before introducing this widget for the first time.
        } else if (action == TourAction.previous) {
            // Do something before returning to this widget from the next step.
        }
    },
    onAfterAction: (introduceResult) async {
        if (introduceResult case TourAction.next || TourAction.done) {
            // Do something after the current widget is shown
            // and the user presses the next or done button.
        } else if (introduceResult == TourAction.previous) {
            // Do something after the user goes back to the previous feature.
        }
    },
    child: TextButton(
        onPressed: () {},
        child: const Text('TextButton 1'),
    ),
)
```

You can also control the active step programmatically from the controller when you build a custom introduction UI:

```dart
tourController.next();
tourController.previous();
tourController.skip();
```

### Start a tour

```dart
@override
void initState() {
        tourController.start(
            context,
            firstStep: TourStep.drawer,
            firstStepTimeout: const Duration(seconds: 3),
        );
    super.initState();
}
```

### Set default configuration

You can set the default configuration for the app using the `FeaturesTour.setGlobalConfig()` method. This sets the default values for all the configuration options for the Features Tour. You can override these values when you create individual tour steps. **Please notice** that this method should be call in `main` method or before the widget is rendered to avoid unexpected behavior. Here is an example:

```dart
void main() {
    // Set the default value for this app. Please notice that this method should be call here or before
    // the widget is rendered to avoid unexpected behavior.
    FeaturesTour.setGlobalConfig(
        /// This value is the base value for all tours, each tour will have its own configurations.
        ///
        /// `true` : force to show all the tours, even the pre-dialogs
        /// `false` : force to not show all the tours and pre-dialogs
        /// `null` (default) : show when needed.
        force: null,

        /// Configuration for the `child` widget.
        childConfig: ChildConfig(
            backgroundColor: Colors.white,
        ),

        /// Configuration for the `Skip` text button.
        skipConfig: SkipConfig(
            text: 'SKIP',
        ),

        /// Configuration for the `Next` text button.
        nextConfig: NextConfig(
            text: 'NEXT'
        ),

        /// Configuration for the `Done` text button.
        doneConfig: DoneConfig(
            text: 'DONE'
        ),

        /// Configuration for the `introduce` widget, can know as the description.
        introduceConfig: IntroduceConfig(
            backgroundColor: Colors.black,
        ),
    );
  
    runApp(const MaterialApp(home: MyApp()));
}
```

With these steps, you can easily create a tour to showcase the features of your app.

## Flows

* The flows of the tour:

### Tour Flow

The following steps outline the flow of a Features Tour:

1. **Start the Tour**\
   Begin the tour by calling the `start` method on the `FeaturesTourController`.

2. **Wait for the First Widget**\
    The tour waits for the first widget to be displayed. Prefer `FeaturesTourController.firstStep` for new code, and use `FeaturesTourController.firstStepTimeout` to control how long the controller waits before falling back to `firstIndex` when one is provided. Legacy `firstIndex` and `firstIndexTimeout` remain available for migration.

3. **Execute Before-Introduction Logic**\
    Before introducing a widget, the `FeaturesTour.onBeforeAction` callback is executed with the action that led to this widget. The first widget receives `TourAction.introduce`, the next widget receives `TourAction.next`, and a widget shown again after going back receives `TourAction.previous`.

    > Important: `onBeforeAction` runs only after the current tour state is already mounted, so use it to prepare the visible widget, such as scrolling it into view. To open a `Drawer` or show a `Dialog` for a later step, trigger that UI from `onAfterAction` in the previous `FeaturesTour`, then use `nextStep` so the controller waits for the newly visible step. To start on a later step, use `firstStep`, and the controller will fall back to `firstIndex` if the step is not available in time.

4. **Show the Introduction**\
   The widget's introduction is displayed, along with navigation buttons:
   * **Next**: Shown if there is a subsequent widget in the tour.
   * **Skip**: Allows the user to skip the tour.
    * **Done**: Shown if the current widget is the last in the tour.
    * **Previous**: Shown if there is a previous widget in the tour.

5. **Execute After-Introduction Logic**\
    After the user interacts with the introduction (e.g., presses `Next`, `Done`, `Skip`, or `Previous`), the `FeaturesTour.onAfterAction` callback is executed. This callback receives the action chosen from the current widget, so it will be `TourAction.next`, `TourAction.done`, `TourAction.skip`, or `TourAction.previous`. Note: `onAfterIntroduce` is deprecated and replaced by `onAfterAction`.

6. **Handle Back Navigation**\
    When the user presses `Previous`, the current widget's `onAfterAction` callback receives `TourAction.previous` first. The controller then attempts to find and wait for the previous step to become available again, for example after reopening a drawer or dialog. It waits up to the step's configured `previousStepTimeout` (default: 3 seconds). If the previous step becomes available within the timeout, the previous widget's `onBeforeAction` callback receives `TourAction.previous` and that widget is shown again. If the previous step is not available before the timeout elapses, the previous action is ignored.

7. **Wait for the Next Widget**\
    The tour waits for the next widget to be displayed. Prefer `FeaturesTour.nextStep` for new code, and use `FeaturesTour.nextStepTimeout` to control how long the controller waits before falling back to the next available step. Legacy `FeaturesTour.nextIndex` and `FeaturesTour.nextIndexTimeout` remain available for migration.

8. **Repeat the Process**\
   Steps 3 to 6 are repeated for each widget in the tour until the last widget is introduced.

By following this flow, you can create an engaging and seamless tour experience for your app's users.

You can also know to the current state of the tour by using `onState` callback:

```dart
tourController.start(
    context,
    onState: (state) {
        switch (state) {
            case TourIntroducing(step: final step):
                print('Introducing: $step');
            default:
        }
    }
);
```

### Handling `Drawer` or `Dialog` in the Tour

When your tour involves introducing widgets inside a `Drawer` or a `Dialog`, you can handle it as follows:

#### Case 1: The Introduced Widget is at the First Index

1. Open the `Drawer` or `Dialog` programmatically:
   * For a `Drawer`, use `scaffoldKey.currentState?.openDrawer()`.
   * For a `Dialog`, use `showDialog()`.

2. Start the tour with the following code:

   ```dart
   tourController.start(context, firstStep: TourStep.buttonOnDialog);
   ```

#### Case 2: The Introduced Widget is at a Later Index (e.g., Index 4)

In the widget at the preceding index (e.g., Tour step details), configure the `FeaturesTour` as follows:

```dart
FeaturesTour(
    // Other configurations...
    step: TourStep.button,
    nextStep: TourStep.buttonOnDrawer, // Specify the next index
    onAfterAction: (introduceResult) {
        if (introduceResult case TourAction.next || TourAction.done) {
            // Open the Drawer or Dialog
            scaffoldKey.currentState?.openDrawer(); // For Drawer
            // or
            showDialog(); // For Dialog
        } else if (introduceResult == TourAction.previous) {
            // Keep the current route/state ready while moving back
        }
    },
    // Other configurations...
)
```

By following these steps, you can effortlessly integrate `Drawer`, `Dialog`, or even widgets from other screens into your tour flow. This ensures a cohesive and intuitive user experience, regardless of the complexity of your app's navigation or UI structure.

### Handling the `ScrollController`

When dealing with widgets that are not immediately visible due to scrolling, you can use the following approaches:

#### Case 1: The Widget is in the Widget Tree but Invisible on the Screen

Use the `FeaturesTour.onBeforeAction` callback to scroll the widget into view. For the first time a step is shown, the callback receives `TourAction.introduce`. If the user goes back to this step from the next widget, it receives `TourAction.previous`. For example:

```dart
FeaturesTour(
    // Other configurations...
    onBeforeAction: (action) async {
        if (action == TourAction.introduce) {
            // Scroll to the end of the list to make the widget visible
            await scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
            );
        } else if (action == TourAction.previous) {
            // Restore the widget position if the user goes back
        }
    },
    // Other configurations...
)
```

This ensures that the widget is brought into the visible area before the introduction begins.

#### Case 2: The Widget is Not in the Widget Tree (e.g., Due to `ListView.builder`)

If the widget is not part of the widget tree (e.g., dynamically created by `ListView.builder`), you can use the approach described in [Handling `Drawer` or `Dialog` in the Tour](#handling-drawer-or-dialog-in-the-tour) to make the widget visible. This involves programmatically triggering the necessary actions to render the widget before introducing it.

By following these methods, you can handle scenarios where widgets are either off-screen or dynamically created, ensuring a smooth and uninterrupted tour experience.

### Handling Bottom Edge Widgets

When introducing widgets located near the bottom edge of the screen, navigation buttons may overlap them. To prevent this, use the built-in `FeaturesTourPadding` widget to add bottom padding during specific tour steps.

```dart
Column(
    children: [
        FeaturesTour(
            controller: tourController,
            index: 1.0,
            introduce: const Text('A bottom edge widget'),
            childConfig: ChildConfig(
                shapeBorder: const CircleBorder(),
                borderSizeInflate: 10.0,
            ),
            child: AnBottomEdgeWidget(),
        ),
        FeaturesTourPadding(
            controller: tourController,
            indexes: {1.0}, // Adds padding when introducing index 1.0
        ),
    ],
)
```

This approach ensures that your bottom edge widgets remain visible and unobstructed during the tour.

## Contributions

Contributions to this project are welcome! If you would like to contribute, please feel free to submit pull requests or open issues.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<p align='center'><a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=lamnhan066&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" width="200"></a></p>

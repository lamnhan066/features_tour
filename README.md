# Features Tour

Features Tour is a package that enables you to easily create tours to introduce your widget features in your app with order. It provides a straightforward and flexible API that allows you to customize the look and feel of the tour to match your app's design.

## Introduction

Demo: [pub.lamnhan.dev/features_tour](https://pub.lamnhan.dev/features_tour)

## Usage

### Create a controller

```dart
// Use this method to set the unique name for the current page.
final tourController = FeaturesTourController('HomePage');
```

### Create a tour widget

```dart
FeaturesTour(
    /// Add the controller
    controller: tourController,

    /// Index of this widget in the tour. It must be unique at the same page 
    /// (using the same `tourController`).
    index: 0.0,

    /// Introduction of this widget (Known as the description of the feature)
    introduce: const Text('This is TextButton 1'),
    
    onBeforeIntroduce: () async {
        // Do something before introducing the current widget
    },

    onAfterIntroduce: (introduceResult) async {
        if (introduceResult case IntroduceResult.next || IntroduceResult.done) {
            // Do something after introducing the current widget
            // and the user press the next or done button.
        }
    }

    /// This is the real widget
    child: TextButton(
        onPressed: () {},
        child: const Text('TextButton 1'),
    ),
),
```

### Start a tour

``` dart
@override
void initState() {
    tourController.start(context);
    super.initState();
}
```

### Set default configuration

You can set the default configuration for the app using the `FeaturesTour.setGlobalConfig()` method. This sets the default values for all the configuration options for the Features Tour. You can override these values when you create individual tour steps. **Please notice** that this method should be call in `main` method or before the widget is rendered to avoid unexpected behavior. Here is an example:

``` dart
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

1. **Start the Tour**  
    Begin the tour by calling the `start` method on the `FeaturesTourController`.

2. **Wait for the First Widget**  
    The tour waits for the first widget to be displayed. This is determined using `FeaturesTourController.firstIndex`. If no specific index is set, the widget with the smallest index will be used as the starting point.

3. **Execute Before-Introduction Logic**  
    Before introducing a widget, the `FeaturesTour.onBeforeIntroduce` callback is executed. This allows you to perform any necessary actions before the introduction begins.

4. **Show the Introduction**  
    The widget's introduction is displayed, along with navigation buttons:
    * **Next**: Shown if there is a subsequent widget in the tour.
    * **Skip**: Allows the user to skip the tour.
    * **Done**: Shown if the current widget is the last in the tour.

5. **Execute After-Introduction Logic**  
    After the user interacts with the introduction (e.g., presses `Next`, `Done`, or `Skip`), the `FeaturesTour.onAfterIntroduce` callback is executed. This callback provides information about the user's action, enabling you to handle it accordingly.

6. **Wait for the Next Widget**  
    The tour waits for the next widget to be displayed. This is determined using `FeaturesTour.nextIndex`.

7. **Repeat the Process**  
    Steps 3 to 6 are repeated for each widget in the tour until the last widget is introduced.

By following this flow, you can create an engaging and seamless tour experience for your app's users.

You can also know to the current state of the tour by using `onState` callback:

```dart
tourController.start(
    context,
    onState: (state) {
        switch (state) {
            case TourIntroducing(index: final index):
                print('Introducing: $index');
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
    tourController.start(context, firstIndex: 1);
    ```

#### Case 2: The Introduced Widget is at a Later Index (e.g., Index 4)

In the widget at the preceding index (e.g., Index 3), configure the `FeaturesTour` as follows:

```dart
FeaturesTour(
     // Other configurations...
     nextIndex: 4, // Specify the next index
     onAfterIntroduce: (introduceResult) {
          if (introduceResult case IntroduceResult.next || IntroduceResult.done) {
                // Open the Drawer or Dialog
                scaffoldKey.currentState?.openDrawer(); // For Drawer
                // or
                showDialog(); // For Dialog
          }
     },
     // Other configurations...
)
```

By following these steps, you can effortlessly integrate `Drawer`, `Dialog`, or even widgets from other screens into your tour flow. This ensures a cohesive and intuitive user experience, regardless of the complexity of your app's navigation or UI structure.

### Handling the `ScrollController`

When dealing with widgets that are not immediately visible due to scrolling, you can use the following approaches:

#### Case 1: The Widget is in the Widget Tree but Invisible on the Screen

Use the `FeaturesTour.onBeforeIntroduce` callback to scroll the widget into view. For example:

```dart
FeaturesTour(
    // Other configurations...
    onBeforeIntroduce: () async {
        // Scroll to the end of the list to make the widget visible
        await scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
        );
    },
    // Other configurations...
)
```

This ensures that the widget is brought into the visible area before the introduction begins.

#### Case 2: The Widget is Not in the Widget Tree (e.g., Due to `ListView.builder`)

If the widget is not part of the widget tree (e.g., dynamically created by `ListView.builder`), you can use the approach described in [Handling `Drawer` or `Dialog` in the Tour](#handling-drawer-or-dialog-in-the-tour) to make the widget visible. This involves programmatically triggering the necessary actions to render the widget before introducing it.

By following these methods, you can handle scenarios where widgets are either off-screen or dynamically created, ensuring a smooth and uninterrupted tour experience.

## Contributions

Contributions to this project are welcome! If you would like to contribute, please feel free to submit pull requests or open issues.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<p align='center'><a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=lamnhan066&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" width="200"></a></p>

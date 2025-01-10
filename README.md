# Features Tour

Features Tour is a package that enables you to easily create tours to introduce your widget features in your app with order. It provides a straightforward and flexible API that allows you to customize the look and feel of the tour to match your app's design.

## Introduction

Demo: [pub.lamnhan.dev/features_tour](https://pub.lamnhan.dev/features_tour)

## Usage

### Create a controller

```dart
// Use this method to set name for this page. This value will prevent the dupplicated `index` issues.
final tourController = FeaturesTourController('HomePage');
```

### Create a tour widget

To create a tour step, you need to create a FeaturesTour widget. This widget takes several configuration options, such as the index of the step, the introduction widget, the child widget, and the position and style of the introduction. Here is an example:

```dart
FeaturesTour(
    /// Add the controller
    controller: tourController,

    /// Index of this widget in the tour. It must be unique at the same page.
    index: 0,

    /// Introduction of this widget (Known as the description of the feature)
    introduce: const Text('This is TextButton 1'),

    /// This is the real widget
    child: TextButton(
        onPressed: () {},
        child: const Text('TextButton 1'),
    ),
),
```

<details>

<summary>Full parameters</summary>

``` dart
FeaturesTour(
    /// Add the controller
    controller: tourController,

    /// Index of this widget in the tour. It must be unique in the same page.
    index: 0,

    /// [Optional] The app will be freezed until this index is appeared, so careful when using this feature.
    waitForIndex: 1,

    /// Timeout for the [waitForIndex] action.
    waitForTimeout: Duration(seconds: 3),

    /// On this widget pressed. This can be a `Future` method, the next introduction will be delayed until this method is completed.
    onPressed: () async {
        // Handle the press event
    },

    /// Introduction of this widget (Known as the description of the feature)
    introduce: const Text('This is TextButton 1'),

    /// Where to place the `introduce` widget.
    introduceConfig: IntroduceConfig(
        // Select the rectangle of the quadrant on the screen
        quadrantAlignment: QuadrantAlignment.bottom,
        // Alignment of the `introduce` widget in the quadrant rectangle
        alignment: Alignment.topCenter,
        // Show the tour above all other overlays
        useRootOverlay: false,
    ),

    /// Config for the next button, this button will move to the next widget base on its' index.
    nextConfig: NextConfig(
        // Use the default `Elevated` button with this text.
        text: 'NEXT',

        // Create your own button.
        child: (onPressed) => ElevatedButton(
            onPressed: onPressed,
            child: Text('NEXT'),
        ),
    ),

    /// Config for the skip button. This button will skip the current tour.
    skipConfig: SkipConfig(
        // Use the default `Elevated` button with this text.
        text: 'SKIP',

        // Create your own button.
        child: (onPressed) => ElevatedButton(
            onPressed: onPressed,
            child: Text('SKIP'),
        ),
    ),

    /// Config for the done button. This button will be shown on the last introduction.
    doneConfig: DoneConfig(
        // Use the default `Elevated` button with this text.
        text: 'DONE',

        // Create your own button.
        child: (onPressed) => ElevatedButton(
            onPressed: onPressed,
            child: Text('DONE'),
        ),
    ),

    /// Config for the pre-dialog, it will show before the tours to ask the permission.
    predialogConfig: PredialogConfig(
      enabled: true,
      // You can add your own dialog here. All others parameters will be ignored when using this method.
      modifiedDialogResult: (context) => showDialog<bool>(context: context, builder: builder),
    ),

    /// Config for the fake child widget. This fake child is default to original `child`.
    childConfig: ChildConfig(
        child: (child) => TextButton(
            onPressed: () {},
            child: const Text('A fake button 1'),
        ),
        backgroundColor: Colors.white,
    ),

    /// This is the real widget
    child: TextButton(
        onPressed: () {},
        child: const Text('TextButton 1'),
    ),
),
```

</details>

### Start a tour

To create a tour, you need to create a FeaturesTourController instance for each page that you want to add tours to. You can then use the controller to start the tour, set the current step, and control the flow of the tour. Here is an example:

``` dart
@override
void initState() {
    // Use this method to start all the available features tour.
    // The `context` will be used to wait for the page transition
    // animation to complete before starting the tour.
    tourController.start(context);
    super.initState();
}
```

<details>

<summary>Full parameters</summary>

``` dart
    // Use this method to start all the available features tour.
    // The `context` will be used to wait for the page transition
    // animation to complete before starting the tour.
    tourController.start(
      /// Context of the current Page
      context,

      /// You can set the first index by setting [waitForFirstIndex] with timeout by
      /// setting [waitForFirstTimeout]. If the timeout is exceeded, the smallest available
      /// index will be used.
      waitForFirstIndex: 1.0,
      waitForFirstTimeout: const Duration(seconds: 3),

      /// Delay before starting the tour
      delay: Duration.zero,

      /// If `true`, it will force to start the tour even already shown.
      /// If `false,` it will force not to start the tour.
      /// Default is `null` (depends on the global config).
      force: false,

      /// Show specific pre-dialog for this Page
      predialogConfig: PredialogConfig(),
    );
```

</details>

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

## Additional

If you want to use `FeaturesTour`s inside a `FeaturesTour`, you need to clone the `Widget`s inside the child `FeaturesTour`s and pass it to the parent `FeaturesTour` in the `childConfig` parameter like below:

```dart
FeaturesTour(
    controller: tourController,
    index: 1,
    childConfig: ChildConfig(
        child: (child) => Row(
            children: [
                Center(
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 1'),
                    ),
                ),
                Center(
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 2'),
                    ),
                ),
            ],
        ),
    ),
    child: Row(
        children: [
            FeaturesTour(
                controller: tourController,
                index: 2,
                child: Center(
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 1'),
                    ),
                ),
            ),
            FeaturesTour(
                controller: tourController,
                index: 3,
                child: Center(
                    child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Button 2'),
                    ),
                ),
            ),
        ]
    ),
)
```

## Contributions

Contributions to this project are welcome! If you would like to contribute, please feel free to submit pull requests or open issues. However, please note that this project is in early development and may not have well-defined contribution guidelines yet. We appreciate your patience and understanding as we work to build a strong and inclusive community around this package.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<p align='center'><a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=lamnhan066&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" width="200"></a></p>

Your donation will be used to cover the cost of maintaining and improving this project. Thank you for your support!

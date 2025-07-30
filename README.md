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

## Contributions

Contributions to this project are welcome! If you would like to contribute, please feel free to submit pull requests or open issues.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<p align='center'><a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a coffee&emoji=&slug=lamnhan066&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00" width="200"></a></p>

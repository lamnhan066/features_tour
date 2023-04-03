# Features Tour

Features Tour is a package that enables you to easily create tours to introduce your widget features in your app with order. It provides a straightforward and flexible API that allows you to customize the look and feel of the tour to match your app's design.

## Usage

Start by importing the package in your Dart code:

``` dart
import 'package:features_tour/features_tour.dart';
```

Then, set the default configuration for the app using the FeaturesTour.setGlobalConfig() method. This sets the default values for all the configuration options for the Features Tour. You can override these values when you create individual tour steps. Here is an example:

``` dart
void main() {
    // Set the default value for this app
    FeaturesTour.setGlobalConfig(
        childConfig: ChildConfig.copyWith(
            backgroundColor: Colors.white,
        ),
        skipConfig: SkipConfig.copyWith(
            text: 'SKIP >>>',
        ),
        nextConfig: NextConfig.copyWith(
            text: 'NEXT >>'
        ),
        introdureConfig: IntrodureConfig.copyWith(
            backgroundColor: Colors.black,
        ),
    );
  
    runApp(const MaterialApp(home: MyApp()));
}
```

To create a tour, you need to create a FeaturesTourController instance for each page that you want to add tours to. You can then use the controller to start the tour, set the current step, and control the flow of the tour. Here is an example:

``` dart
// Use this method to set name for this page. This value will prevent the dupplicated `index` issues.
final tourController = FeaturesTourController('MyApp');

@override
void initState() {
    // Use this method to start all the available features tour.
    // The `context` will be used to wait for the page transition
    // animation to complete before starting the tour.
    tourController.start(context: context, isDebug: true);
    super.initState();
}
```

To create a tour step, you need to create a FeaturesTour widget. This widget takes several configuration options, such as the index of the step, the introduction widget, the child widget, and the position and style of the introduction. Here is an example:

``` dart
FeaturesTour(
    // Add the controller
    controller: tourController,
    // Index of this widget in the tour. It must be unique in the same page.
    index: 0,
    // Introduction of this widget
    introdure: const Text(
        'This is TextButton 1',
        style: TextStyle(color: Colors.white),
    ),
    // Where to place the `introdure` widget.
    introdureConfig: IntrodureConfig.copyWith(
        // Select the rectangle of the quadrant on the screen
        quadrantAlignment: QuadrantAlignment.bottom,
        // Alignment of the `introdure` widget in the quadrant rectangle
        alignment: Alignment.topCenter,
    ),
    // Config for the fake child widget. This fake child is default to original `child`.
    childConfig: ChildConfig.copyWith(
        backgroundColor: Colors.white,
    ),
    // Config for the next button, this button will move to the next widget base on its' index.
    nextConfig: NextConfig.copyWith(
        text: 'NEXT >>',
    ),
    // Config for the skip button. This button will skip the current tour.
    skipConfig: SkipConfig.copyWith(
        text: 'SKIP >>>',
    ),
    // Config for the pre-dialog, it will show before the tours to ask the permission.
    predialogConfig: PredialogConfig.copyWith(
      enabled: true,
    ),
    // This is the real widget
    child: TextButton(
        onPressed: () {},
        child: const Text('TextButton 1'),
    ),
),
```

With these steps, you can easily create a tour to showcase the features of your app.

## Contributions

Contributions to this project are welcome! If you would like to contribute, please feel free to submit pull requests or open issues. However, please note that this project is in early development and may not have well-defined contribution guidelines yet. We appreciate your patience and understanding as we work to build a strong and inclusive community around this package.

## Donations

If you find this project helpful and would like to support its development, you can make a donation through the following channels:

**PayPal:** [Donate Now](https://www.paypal.com/donate?hosted_button_id=lamnhan066)

<a href="https://www.buymeacoffee.com/lamnhan066"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png" alt="Buy Me A Coffee" width="150"></a>

Your donation will be used to cover the cost of maintaining and improving this project. Thank you for your support!

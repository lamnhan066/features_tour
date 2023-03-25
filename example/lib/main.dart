import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FeaturesTourController.start().then((value) => print('Completed'));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FeaturesTour(
              globalKey: GlobalKey(),
              index: 1,
              introdure: const Text(
                'You need to press Ok to close this introdure method',
                style: TextStyle(color: Colors.white),
              ),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('A');
                  },
                  child: const Text('Ok'),
                ),
              ),
            ),
            FeaturesTour(
              globalKey: GlobalKey(),
              index: 0,
              introdure: const Text(
                'You need to press Ok to close this introdure method',
                style: TextStyle(color: Colors.white),
              ),
              verticalAlignment: VerticalAlignment.bottom,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    print('A');
                  },
                  child: const Text('Ok 1'),
                ),
              ),
              onTap: () async {
                print('okk');
              },
            ),
          ],
        ),
        floatingActionButton: FeaturesTour(
          globalKey: GlobalKey(),
          index: 3,
          introdure: const Text(
            'Press this button to add something',
            style: TextStyle(color: Colors.white),
          ),
          horizontalAligment: HorizontalAligment.right,
          verticalAlignment: VerticalAlignment.top,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}

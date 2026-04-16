import 'package:features_tour/src/models/introduce_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('default builder applies color based on theme (light => white)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Builder(
          builder: (context) {
            final widget = IntroduceConfig().builder(
              context,
              const Rect.fromLTWH(0, 0, 10, 10),
              const Text('intro'),
            );
            return Scaffold(body: Center(child: widget));
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final defaultStyle =
        DefaultTextStyle.of(tester.element(find.text('intro'))).style;
    expect(defaultStyle.color, equals(Colors.white));
  });

  testWidgets('custom builder passed to IntroduceConfig is used', (
    tester,
  ) async {
    final customKey = UniqueKey();
    final custom = IntroduceConfig(
      builder: (context, rect, child) {
        return Container(key: customKey, child: child);
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final widget = custom.builder(
              context,
              const Rect.fromLTWH(1, 2, 3, 4),
              const Text('hello'),
            );
            return Scaffold(body: Center(child: widget));
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(customKey), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
  });
}

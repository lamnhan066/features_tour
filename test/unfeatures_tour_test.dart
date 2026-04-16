import 'package:features_tour/src/components/unfeatures_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('isUnfeaturesTour returns false for null or outside context', (
    tester,
  ) async {
    expect(UnfeaturesTour.isUnfeaturesTour(null), isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('no-unfeatures'))),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold));
    expect(UnfeaturesTour.isUnfeaturesTour(context), isFalse);
  });

  testWidgets('isUnfeaturesTour returns true when wrapped', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UnfeaturesTour(
          child: Builder(
            builder: (context) {
              return Text(UnfeaturesTour.isUnfeaturesTour(context).toString());
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('true'), findsOneWidget);
  });

  test('updateShouldNotify is false', () {
    const a = UnfeaturesTour(child: SizedBox());
    const b = UnfeaturesTour(child: SizedBox());
    expect(a.updateShouldNotify(b), isFalse);
  });
}

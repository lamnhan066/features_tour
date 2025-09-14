import 'package:features_tour/features_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FeaturesTourPadding', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FeaturesTour.setGlobalConfig(
        preDialogConfig: PreDialogConfig(enabled: false),
        nextConfig: NextConfig(text: 'Next'),
        doneConfig: DoneConfig(text: 'Done'),
        skipConfig: SkipConfig(text: 'Skip'),
      );
    });

    testWidgets(
      'applies and removes padding when tour index matches',
      (WidgetTester tester) async {
        final controller = FeaturesTourController('test_page');
        const padding = EdgeInsets.all(25);
        const animationDuration = Duration(milliseconds: 500);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      FeaturesTour(
                        controller: controller,
                        index: 1,
                        introduce: const Text('Feature 1'),
                        child: const SizedBox(width: 10, height: 10),
                      ),
                      FeaturesTourPadding(
                        controller: controller,
                        indexes: {1.0},
                        padding: padding,
                        animationDuration: animationDuration,
                        child: const SizedBox(key: Key('padded_child')),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final paddingFinder = find.ancestor(
          of: find.byKey(const Key('padded_child')),
          matching: find.byType(AnimatedPadding),
        );

        var animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);

        final BuildContext context = tester.element(find.byType(Scaffold));

        await tester.runAsync(() async {
          await controller.start(
            context,
            delay: Duration.zero,
            onState: (state) async {
              if (state case TourIntroducing()) {
                await tester.pump();

                animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
                expect(animatedPadding.padding, padding);

                await tester.pump(animationDuration);

                expect(find.text('Done'), findsOneWidget);
                await tester.tap(find.text('Done'));
              }
            },
          );
        });

        await tester.pumpAndSettle();

        animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);
      },
    );

    testWidgets(
      'does not apply padding when tour index does not match',
      (WidgetTester tester) async {
        final controller = FeaturesTourController('test_page');
        const padding = EdgeInsets.all(25);
        const animationDuration = Duration(milliseconds: 500);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      FeaturesTour(
                        controller: controller,
                        index: 1,
                        introduce: const Text('Feature 1'),
                        child: const SizedBox(width: 10, height: 10),
                      ),
                      FeaturesTourPadding(
                        controller: controller,
                        indexes: {2.0},
                        padding: padding,
                        animationDuration: animationDuration,
                        child: const SizedBox(key: Key('padded_child')),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final paddingFinder = find.ancestor(
          of: find.byKey(const Key('padded_child')),
          matching: find.byType(AnimatedPadding),
        );

        var animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);

        final BuildContext context = tester.element(find.byType(Scaffold));

        await tester.runAsync(() async {
          await controller.start(
            context,
            delay: Duration.zero,
            onState: (state) async {
              if (state case TourIntroducing()) {
                await tester.pump();

                animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
                expect(animatedPadding.padding, EdgeInsets.zero);

                await tester.pump(animationDuration);

                expect(find.text('Done'), findsOneWidget);
                await tester.tap(find.text('Done'));
              }
            },
          );
        });

        await tester.pumpAndSettle();

        animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);
      },
    );

    testWidgets(
      'applies padding for one of multiple indexes',
      (WidgetTester tester) async {
        final controller = FeaturesTourController('test_page');
        const padding = EdgeInsets.all(25);
        const animationDuration = Duration(milliseconds: 500);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Column(
                    children: [
                      FeaturesTour(
                        controller: controller,
                        index: 1,
                        nextIndex: 2,
                        introduce: const Text('Feature 1'),
                        child: const SizedBox(width: 10, height: 10),
                      ),
                      FeaturesTour(
                        controller: controller,
                        index: 2,
                        introduce: const Text('Feature 2'),
                        child: const SizedBox(width: 10, height: 10),
                      ),
                      FeaturesTourPadding(
                        controller: controller,
                        indexes: {2.0},
                        padding: padding,
                        animationDuration: animationDuration,
                        child: const SizedBox(key: Key('padded_child')),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final paddingFinder = find.ancestor(
          of: find.byKey(const Key('padded_child')),
          matching: find.byType(AnimatedPadding),
        );

        var animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);

        final BuildContext context = tester.element(find.byType(Scaffold));

        await tester.runAsync(() async {
          await controller.start(
            context,
            delay: Duration.zero,
            onState: (state) async {
              if (state case TourIntroducing(index: 1.0)) {
                await tester.pump();

                // At index 1.0, no padding.
                animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
                expect(animatedPadding.padding, EdgeInsets.zero);
                expect(find.text('Feature 1'), findsOneWidget);

                await tester.tap(find.text('Next'));
              }
              if (state case TourIntroducing(index: 2.0)) {
                await tester.pump();

                // At index 2.0, padding should be applied.
                animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
                expect(animatedPadding.padding, padding);
                expect(find.text('Feature 2'), findsOneWidget);

                await tester.tap(find.text('Done'));
              }
            },
          );
        });

        await tester.pumpAndSettle();

        animatedPadding = tester.widget<AnimatedPadding>(paddingFinder);
        expect(animatedPadding.padding, EdgeInsets.zero);
      },
    );
  });
}

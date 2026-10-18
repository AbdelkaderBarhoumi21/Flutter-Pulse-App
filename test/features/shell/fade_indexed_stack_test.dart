import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_pulse_app/features/shell/presentation/widgets/fade_indexed_stack.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget stack(int index) => MaterialApp(
    home: FadeIndexedStack(
      index: index,
      children: const [Text('first'), Text('second')],
    ),
  );

  double opacityOf(WidgetTester tester, String text) {
    final opacity = tester.widget<AnimatedOpacity>(
      find.ancestor(
        of: find.text(text),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    return opacity.opacity;
  }

  // Regression guard: the fade must sit outside the hidden tab's disabled
  // TickerMode, otherwise the fade-out never runs and the old tab stays
  // half visible.
  testWidgets('the previous tab fades out completely', (tester) async {
    await tester.pumpWidget(stack(0));
    await tester.pumpWidget(stack(1));
    await tester.pumpAndSettle();

    expect(opacityOf(tester, 'first'), 0);
    expect(opacityOf(tester, 'second'), 1);

    final fade = tester.renderObject<RenderAnimatedOpacity>(
      find.ancestor(
        of: find.text('first'),
        matching: find.byType(AnimatedOpacity),
      ),
    );
    expect(fade.opacity.value, 0);
  });

  testWidgets('hidden tabs keep their state but ignore input', (tester) async {
    await tester.pumpWidget(stack(1));
    expect(find.text('first'), findsOneWidget); // still mounted

    final ignore = tester.widget<IgnorePointer>(
      find
          .ancestor(
            of: find.text('first'),
            matching: find.byType(IgnorePointer),
          )
          .first,
    );
    expect(ignore.ignoring, isTrue);
  });
}

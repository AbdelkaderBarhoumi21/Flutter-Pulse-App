import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/errors/failures.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_button.dart';
import 'package:flutter_pulse_app/core/widgets/app_list_tile.dart';
import 'package:flutter_pulse_app/core/widgets/async_value_view.dart';
import 'package:flutter_pulse_app/core/widgets/choice_chip_group.dart';
import 'package:flutter_pulse_app/core/widgets/confirm_dialog.dart';
import 'package:flutter_pulse_app/core/widgets/pressable_scale.dart';
import 'package:flutter_pulse_app/core/widgets/state_message_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('StateMessageView.error', () {
    testWidgets('shows a friendly message and retries', (tester) async {
      var retries = 0;
      await pumpThemed(
        tester,
        StateMessageView.error(
          error: const ServerFailure('Server error: 500'),
          onRetry: () => retries++,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.errorServer), findsOneWidget);
      expect(find.textContaining('500'), findsNothing);
      await tester.tap(find.text(AppStrings.retry));
      expect(retries, 1);
    });

    testWidgets('uses the offline icon for network failures', (tester) async {
      await pumpThemed(
        tester,
        StateMessageView.error(error: const NetworkFailure()),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text(AppStrings.retry), findsNothing);
    });
  });

  group('AsyncValueView', () {
    Widget view(AsyncValue<String> value) => AsyncValueView<String>(
      value: value,
      loading: const Text('loading'),
      data: Text.new,
      onRetry: () {},
    );

    testWidgets('renders each state', (tester) async {
      await pumpThemed(tester, view(const AsyncLoading()));
      expect(find.text('loading'), findsOneWidget);

      await pumpThemed(tester, view(const AsyncData('hello')));
      await tester.pumpAndSettle();
      expect(find.text('hello'), findsOneWidget);

      await pumpThemed(
        tester,
        view(const AsyncError(NetworkFailure(), StackTrace.empty)),
      );
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.errorNetwork), findsOneWidget);
    });

    testWidgets('keeps data visible while refreshing', (tester) async {
      await pumpThemed(
        tester,
        view(
          const AsyncLoading<String>().copyWithPrevious(const AsyncData('old')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('old'), findsOneWidget);
      expect(find.text('loading'), findsNothing);
    });
  });

  group('AppButton', () {
    testWidgets('is disabled without a callback', (tester) async {
      await pumpThemed(tester, const AppButton(label: 'Go', onPressed: null));
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows a spinner and ignores taps while loading', (
      tester,
    ) async {
      var taps = 0;
      await pumpThemed(
        tester,
        AppButton(label: 'Go', isLoading: true, onPressed: () => taps++),
      );
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Go'), findsNothing);
      await tester.tap(find.byType(FilledButton));
      expect(taps, 0);
    });
  });

  testWidgets('ChoiceChipGroup reports the tapped option', (tester) async {
    int? selected;
    await pumpThemed(
      tester,
      ChoiceChipGroup<int>(
        options: const [1, 2, 3],
        selected: 1,
        onSelected: (value) => selected = value,
        labelOf: (value) => 'Option $value',
      ),
    );
    await tester.tap(find.text('Option 3'));
    expect(selected, 3);
  });

  testWidgets('PressableScale shrinks while pressed', (tester) async {
    await pumpThemed(
      tester,
      const Center(
        child: PressableScale(
          child: ColoredBox(
            color: Color(0xFF000000),
            child: SizedBox.square(dimension: 80),
          ),
        ),
      ),
    );
    double scale() =>
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PressableScale)),
    );
    await tester.pump();
    expect(scale(), lessThan(1));

    await gesture.up();
    await tester.pump();
    expect(scale(), 1);
  });

  testWidgets('AppListTile shows a chevron only when tappable', (tester) async {
    await pumpThemed(
      tester,
      Column(
        children: [
          const AppListTile(icon: Icons.info, title: 'Static'),
          AppListTile(icon: Icons.star, title: 'Tappable', onTap: () {}),
        ],
      ),
    );
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
  });

  testWidgets('showConfirmDialog resolves to the user choice', (tester) async {
    late BuildContext context;
    await pumpThemed(
      tester,
      Builder(
        builder: (c) {
          context = c;
          return const SizedBox();
        },
      ),
    );

    final cancelled = showConfirmDialog(
      context,
      title: 'Delete?',
      message: 'Sure?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(await cancelled, isFalse);

    final confirmed = showConfirmDialog(
      context,
      title: 'Delete?',
      message: 'Sure?',
      confirmLabel: 'Delete',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await confirmed, isTrue);
  });

  testWidgets('context.showError shows a friendly snack bar', (tester) async {
    await pumpThemed(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => context.showError(const UnexpectedFailure('raw')),
          child: const Text('fail'),
        ),
      ),
    );
    await tester.tap(find.text('fail'));
    await tester.pump();
    expect(find.text(AppStrings.errorUnexpected), findsOneWidget);
    expect(find.text('raw'), findsNothing);
  });
}

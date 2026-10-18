import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/app/pulse_app.dart';
import 'package:flutter_pulse_app/core/constants/app_layout.dart';
import 'package:flutter_pulse_app/core/storage/shared_preferences_provider.dart';
import 'package:flutter_pulse_app/core/theme/app_theme.dart';
import 'package:flutter_pulse_app/core/utils/clock_provider.dart';
import 'package:flutter_pulse_app/features/task/domain/repositories/task_repository.dart';
import 'package:flutter_pulse_app/features/task/presentation/providers/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'task_factory.dart';

/// Gives the test a phone-sized surface (default 390×844 logical px).
void usePhoneSurface(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view
    ..devicePixelRatio = 3
    ..physicalSize = size * 3;
  addTearDown(tester.view.reset);
}

/// Pumps a single widget inside the app's theme and ScreenUtil scaling.
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  ThemeMode themeMode = ThemeMode.light,
  List<Override> overrides = const [],
}) async {
  usePhoneSurface(tester);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: ScreenUtilInit(
        designSize: AppLayout.phoneDesignSize,
        builder: (_, _) => MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: Scaffold(body: child),
        ),
      ),
    ),
  );
}

/// Pumps the whole app (real router, theme and shell) on a fake backend.
Future<ProviderContainer> pumpPulseApp(
  WidgetTester tester, {
  required TaskRepository repository,
  Map<String, Object> preferences = const {},
  Size size = const Size(390, 844),
}) async {
  usePhoneSurface(tester, size: size);
  SharedPreferences.setMockInitialValues(preferences);
  PackageInfo.setMockInitialValues(
    appName: 'Pulse',
    packageName: 'com.example.pulse',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      taskRepositoryProvider.overrideWithValue(repository),
      clockProvider.overrideWithValue(() => testNow),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const PulseApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

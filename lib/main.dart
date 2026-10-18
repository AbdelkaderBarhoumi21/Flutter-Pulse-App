import 'package:flutter/widgets.dart';
import 'package:flutter_pulse_app/app/pulse_app.dart';
import 'package:flutter_pulse_app/core/notifications/firebase_initializer.dart';
import 'package:flutter_pulse_app/core/notifications/notification_providers.dart';
import 'package:flutter_pulse_app/core/storage/shared_preferences_provider.dart';
import 'package:flutter_pulse_app/features/device/presentation/providers/device_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrap only: platform services, dependency bindings, `runApp`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final (firebaseAvailable, preferences) = await (
    FirebaseInitializer.initialize(),
    SharedPreferences.getInstance(),
  ).wait;

  runApp(
    ProviderScope(
      overrides: [
        firebaseAvailableProvider.overrideWithValue(firebaseAvailable),
        sharedPreferencesProvider.overrideWithValue(preferences),
        // Core's push layer depends on the PushTokenRegistrar port; the
        // device feature implements it. Bound here, at the composition root.
        pushTokenRegistrarProvider.overrideWith(
          (ref) => ref.watch(registerDeviceUseCaseProvider),
        ),
      ],
      child: const PulseApp(),
    ),
  );
}

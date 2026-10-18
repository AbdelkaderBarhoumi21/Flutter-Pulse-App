import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/appearance_mode_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/notifications/notification_payload.dart';
import 'package:flutter_pulse_app/core/notifications/notification_providers.dart';
import 'package:flutter_pulse_app/core/routing/app_router.dart';
import 'package:flutter_pulse_app/core/routing/notification_route_resolver.dart';
import 'package:flutter_pulse_app/core/theme/app_theme.dart';
import 'package:flutter_pulse_app/core/utils/responsive_design.dart';
import 'package:flutter_pulse_app/features/settings/presentation/providers/appearance_mode_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Root widget: responsive scaling, themes, router and push wiring.
class PulseApp extends ConsumerStatefulWidget {
  const PulseApp({super.key});

  @override
  ConsumerState<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends ConsumerState<PulseApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startPush());
  }

  void _startPush() {
    if (!mounted || !ref.read(firebaseAvailableProvider)) return;
    unawaited(
      ref.read(pushNotificationServiceProvider).start(onTap: _openFromPush),
    );
  }

  void _openFromPush(NotificationPayload payload) {
    ref.read(appRouterProvider).go(NotificationRouteResolver.resolve(payload));
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final appearance = ref.watch(appearanceModeControllerProvider);
    // `sizeOf` only rebuilds on size changes — not when the keyboard opens.
    final designSize = ResponsiveDesign.designSizeFor(
      MediaQuery.sizeOf(context),
    );

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, _) => MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: appearance.themeMode,
        routerConfig: router,
        builder: (context, child) => _AppChrome(child: child!),
      ),
    );
  }
}

/// Theme-aware app-wide defaults: status-bar icon colours (screens with a
/// coloured header override this locally) and the skeleton shimmer.
class _AppChrome extends StatelessWidget {
  const _AppChrome({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppTheme.overlayStyleFor(context.theme.brightness),
      child: SkeletonizerConfig(
        data: AppTheme.skeletonFor(context.colors),
        child: child,
      ),
    );
  }
}

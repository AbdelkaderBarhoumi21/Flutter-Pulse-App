import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/router/app_routes_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutesNames.home,
    routes: [
      GoRoute(
        name: AppRoutesNames.home,
        path: AppRoutesNames.home,
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
  //! Todo:  Bootstrap FCM ONCE the router exists, so taps can navigate.

  return router;
});

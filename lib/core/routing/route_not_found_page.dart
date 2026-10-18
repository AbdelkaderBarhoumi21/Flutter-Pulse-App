import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/routing/app_navigation.dart';
import 'package:flutter_pulse_app/core/widgets/state_message_view.dart';

/// Shown for unknown locations instead of GoRouter's default error page.
class RouteNotFoundPage extends StatelessWidget {
  const RouteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StateMessageView(
        icon: Icons.explore_off_rounded,
        title: AppStrings.errorNotFoundTitle,
        message: AppStrings.errorNotFoundMessage,
        actionLabel: AppStrings.goHome,
        actionIcon: Icons.home_rounded,
        onAction: context.goToTasks,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_pulse_app/core/constants/app_spacing.dart';
import 'package:flutter_pulse_app/core/constants/app_strings.dart';
import 'package:flutter_pulse_app/core/extensions/animate_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/appearance_mode_extensions.dart';
import 'package:flutter_pulse_app/core/extensions/context_extensions.dart';
import 'package:flutter_pulse_app/core/widgets/app_list_tile.dart';
import 'package:flutter_pulse_app/core/widgets/page_header.dart';
import 'package:flutter_pulse_app/core/widgets/tile_group.dart';
import 'package:flutter_pulse_app/features/settings/presentation/providers/appearance_mode_controller.dart';
import 'package:flutter_pulse_app/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_pulse_app/features/settings/presentation/widgets/appearance_mode_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appearanceModeControllerProvider);
    final version =
        ref.watch(appVersionProvider).valueOrNull ?? AppStrings.notAvailable;
    final host = ref.watch(apiHostProvider);

    final groups = <Widget>[
      TileGroup(
        title: AppStrings.sectionAppearance,
        children: [
          AppListTile(
            icon: Icons.palette_outlined,
            title: AppStrings.themeTitle,
            subtitle: mode.label,
            trailing: AppearanceModeSelector(
              selected: mode,
              onSelected: ref
                  .read(appearanceModeControllerProvider.notifier)
                  .select,
            ),
          ),
        ],
      ),
      TileGroup(
        title: AppStrings.sectionPreferences,
        children: [
          AppListTile(
            icon: Icons.notifications_none_rounded,
            title: AppStrings.notificationsTitle,
            subtitle: AppStrings.notificationsSubtitle,
            onTap: context.showComingSoon,
          ),
          AppListTile(
            icon: Icons.translate_rounded,
            title: AppStrings.languageTitle,
            subtitle: AppStrings.languageSubtitle,
            onTap: context.showComingSoon,
          ),
        ],
      ),
      TileGroup(
        title: AppStrings.sectionAbout,
        children: [
          AppListTile(
            icon: Icons.info_outline_rounded,
            title: AppStrings.versionTitle,
            subtitle: version,
          ),
          AppListTile(
            icon: Icons.dns_outlined,
            title: AppStrings.serverTitle,
            subtitle: host,
          ),
          AppListTile(
            icon: Icons.shield_outlined,
            title: AppStrings.privacyTitle,
            subtitle: AppStrings.privacySubtitle,
            onTap: context.showComingSoon,
          ),
          AppListTile(
            icon: Icons.star_outline_rounded,
            title: AppStrings.rateTitle,
            subtitle: AppStrings.rateSubtitle,
            onTap: context.showComingSoon,
          ),
        ],
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const PageHeader(title: AppStrings.settingsTitle),
            SliverPadding(
              padding: context.pagePadding.copyWith(bottom: AppSpacing.xl.h),
              sliver: SliverList.separated(
                itemCount: groups.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.xl.h),
                itemBuilder: (_, index) =>
                    groups[index].entrance(index: index + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

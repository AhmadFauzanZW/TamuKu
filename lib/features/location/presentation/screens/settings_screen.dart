import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../shared/blocs/settings/settings_cubit.dart';
import '../../../../shared/blocs/settings/settings_state.dart';
import '../../data/services/csv_export_service.dart';

/// Admin settings screen.
///
/// Shows the location profile, preference toggles (dark mode +
/// Telegram notifications) backed by [SettingsCubit], a CSV export
/// action, and a logout button that dispatches [LogoutRequested].
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(prefs: getIt())),
        BlocProvider(create: (_) => getIt<AuthBloc>()),
      ],
      child: const SettingsView(),
    );
  }
}

/// Presentation layer of the settings screen. All state comes from
/// [SettingsCubit]; no `setState` is used.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppConstants.settingsTitle),
        backgroundColor: AppColors.primary900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _sectionLabel(AppConstants.sectionProfileLocation),
            const _ProfileCard(),
            _sectionLabel(AppConstants.sectionPreferences),
            const _PreferencesCard(),
            const SizedBox(height: AppSpacing.xl),
            const _ExportButton(),
            const SizedBox(height: AppSpacing.md),
            const _LogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(text, style: AppTextStyles.overline),
    );
  }
}

/// Card listing the read-only location profile fields.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: const Column(
        children: [
          _ProfileTile(
            icon: Icons.location_on_outlined,
            label: AppConstants.locationNameLabel,
            value:
                'Kantor Desa Cakrawala', // TODO: fetch from Firestore LocationEntity
          ),
          Divider(height: 1, color: AppColors.border),
          _ProfileTile(
            icon: Icons.map_outlined,
            label: AppConstants.addressLabel,
            value:
                'Jl. Merdeka No. 10, Bandung', // TODO: fetch from Firestore LocationEntity
          ),
          Divider(height: 1, color: AppColors.border),
          _ProfileTile(
            icon: Icons.phone_outlined,
            label: AppConstants.hostPhoneLabel,
            value:
                '+6281234567890', // TODO: fetch from Firestore LocationEntity
          ),
        ],
      ),
    );
  }
}

/// Single profile row displaying a label and its current value.
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary700),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(value, style: AppTextStyles.bodyLarge),
    );
  }
}

/// Card holding the dark mode and notification toggle switches.
class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final cubit = context.read<SettingsCubit>();
          return Column(
            children: [
              SwitchListTile(
                secondary: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.primary700,
                ),
                title: const Text(
                  AppConstants.whatsappNotificationLabel,
                  style: AppTextStyles.bodyLarge,
                ),
                activeThumbColor: AppColors.primary700,
                value: state.notificationsEnabled,
                onChanged: cubit.setNotifications,
              ),
              const Divider(height: 1, color: AppColors.border),
              SwitchListTile(
                secondary: const Icon(
                  Icons.dark_mode_outlined,
                  color: AppColors.primary700,
                ),
                title: const Text(
                  AppConstants.darkModeLabel,
                  style: AppTextStyles.bodyLarge,
                ),
                activeThumbColor: AppColors.primary700,
                value: state.darkMode,
                onChanged: cubit.setDarkMode,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-width button that builds and shares the guest CSV export.
class _ExportButton extends StatelessWidget {
  const _ExportButton();

  Future<void> _onExport(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Empty list for MVP; real guest data wired via LocationBloc later.
      await getIt<CsvExportService>().exportAndShare(const []);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text(AppConstants.exportFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => _onExport(context),
        icon: const Icon(Icons.download_outlined),
        label: const Text(
          AppConstants.actionExportCSV,
          style: AppTextStyles.button,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
        ),
      ),
    );
  }
}

/// Full-width destructive button that confirms then logs the admin out.
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  Future<void> _confirmLogout(BuildContext context) async {
    final authBloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppConstants.logoutConfirmTitle),
        content: const Text(AppConstants.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppConstants.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppConstants.logoutButton,
              style: TextStyle(color: AppColors.accentRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      authBloc.add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => _confirmLogout(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentRed,
          side: const BorderSide(color: AppColors.accentRed, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.xlBorder),
        ),
        child: const Text(
          AppConstants.logoutButton,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.accentRed,
          ),
        ),
      ),
    );
  }
}

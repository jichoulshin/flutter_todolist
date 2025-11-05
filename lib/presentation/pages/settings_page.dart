import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../services/battery_optimization_service.dart';
import '../../services/notification_service.dart';
import '../cubits/settings_cubit.dart';
import '../cubits/settings_state.dart';
import '../cubits/task_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: EdgeInsets.symmetric(vertical: 16.r),
            children: [
              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              _buildThemeSelector(context, state),
              _buildLanguageSelector(context, state),

              SizedBox(height: 24.r),

              // Notifications Section
              _buildSectionHeader(context, 'Notifications'),
              _buildNotificationToggle(context, state),
              if (state.notificationsEnabled) ...[
                _buildNotificationTimePicker(context, state),
                _buildBatteryOptimizationButton(context),
                _buildImmediateTestButton(context),
                _buildTestNotificationButton(context),
              ],

              SizedBox(height: 24.r),

              // Data Management Section
              _buildSectionHeader(context, 'Data Management'),
              _buildClearCompletedTasksTile(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsState state) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.r),
                Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            SizedBox(height: 16.r),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (Set<ThemeMode> modes) {
                  context.read<SettingsCubit>().setThemeMode(modes.first);
                },
                showSelectedIcon: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, SettingsState state) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 12.r),
                Text(
                  'Language',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 16.r),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('English')),
                  ButtonSegment(value: 'ko', label: Text('한국어')),
                ],
                selected: {state.languageCode},
                onSelectionChanged: (Set<String> codes) async {
                  final code = codes.first;
                  await context.read<SettingsCubit>().setLanguage(code);
                  if (context.mounted) {
                    await context.setLocale(Locale(code));
                  }
                },
                showSelectedIcon: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationToggle(BuildContext context, SettingsState state) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: SwitchListTile(
        secondary: Icon(
          Icons.notifications_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Enable Notifications'),
        subtitle: const Text('Get reminders for your tasks'),
        value: state.notificationsEnabled,
        onChanged: (value) {
          context.read<SettingsCubit>().setNotificationsEnabled(value);
        },
      ),
    );
  }

  Widget _buildNotificationTimePicker(
    BuildContext context,
    SettingsState state,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: ListTile(
        leading: Icon(
          Icons.timer_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Reminder Time'),
        subtitle: Text('${state.notificationMinutesBefore} minutes before'),
        trailing: DropdownButton<int>(
          value: state.notificationMinutesBefore,
          underline: const SizedBox(),
          items: [5, 10, 15, 30, 60].map((minutes) {
            return DropdownMenuItem(
              value: minutes,
              child: Text('$minutes min'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<SettingsCubit>().setNotificationMinutesBefore(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildBatteryOptimizationButton(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: ListTile(
        leading: const Icon(Icons.battery_saver, color: Colors.green),
        title: const Text('Battery Optimization'),
        subtitle: const Text(
          'Allow unrestricted battery usage for notifications',
        ),
        trailing: const Icon(Icons.settings),
        onTap: () async {
          final isIgnoring =
              await BatteryOptimizationService.isIgnoringBatteryOptimizations();

          if (isIgnoring) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Battery optimization already disabled!'),
                  duration: AppConstants.snackBarDuration,
                ),
              );
            }
          } else {
            final granted =
                await BatteryOptimizationService.requestIgnoreBatteryOptimizations();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    granted
                        ? '✅ Battery optimization disabled successfully!'
                        : '❌ Please disable battery optimization manually in settings',
                  ),
                  duration: AppConstants.snackBarDuration,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildImmediateTestButton(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: ListTile(
        leading: Icon(Icons.bolt, color: Colors.orange),
        title: const Text('Test Immediate Notification'),
        subtitle: const Text('Send notification NOW (no delay)'),
        trailing: const Icon(Icons.send),
        onTap: () async {
          await NotificationService().sendImmediateTestNotification();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 Immediate notification sent!'),
                duration: AppConstants.snackBarDuration,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTestNotificationButton(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: ListTile(
        leading: Icon(
          Icons.notifications_active,
          color: Theme.of(context).colorScheme.secondary,
        ),
        title: const Text('Test Notification'),
        subtitle: const Text('Send a test notification in 5 seconds'),
        trailing: const Icon(Icons.send),
        onTap: () async {
          await NotificationService().sendTestNotification();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🔔 Test notification will arrive in 5 seconds!'),
                duration: AppConstants.snackBarDuration,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildClearCompletedTasksTile(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.r, vertical: 4.r),
      child: ListTile(
        leading: Icon(
          Icons.delete_sweep_outlined,
          color: Theme.of(context).colorScheme.error,
        ),
        title: const Text('Clear Completed Tasks'),
        subtitle: const Text('Remove all completed tasks'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Clear Completed Tasks?'),
              content: const Text(
                'This will permanently delete all completed tasks. This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<TaskCubit>().deleteCompletedTasks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Completed tasks cleared')),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

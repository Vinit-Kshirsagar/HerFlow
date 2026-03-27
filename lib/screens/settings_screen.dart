import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTypography.displaySmall),
                  const SizedBox(height: 24),
                  _sectionTitle('Profile'),
                  _buildTile(
                    emoji: '👤',
                    title: provider.profile.name.isEmpty
                        ? 'Set your name'
                        : provider.profile.name,
                    subtitle: 'Tap to edit',
                    onTap: () => _editName(context, provider),
                  ),
                  _buildTile(
                    emoji: '📅',
                    title: 'Cycle Length',
                    subtitle:
                        '${provider.profile.cycleLength} days',
                    onTap: () => _editNumber(
                      context,
                      'Cycle Length',
                      provider.profile.cycleLength,
                      (v) {
                        final updated =
                            provider.profile.copyWith(cycleLength: v);
                        provider.saveProfile(updated);
                      },
                    ),
                  ),
                  _buildTile(
                    emoji: '🩸',
                    title: 'Period Duration',
                    subtitle:
                        '${provider.profile.periodDuration} days',
                    onTap: () => _editNumber(
                      context,
                      'Period Duration',
                      provider.profile.periodDuration,
                      (v) {
                        final updated =
                            provider.profile.copyWith(periodDuration: v);
                        provider.saveProfile(updated);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('About'),
                  _buildTile(
                    emoji: '🌙',
                    title: 'HerFlow',
                    subtitle: 'v1.0.0 — Made with 💕',
                    onTap: () {},
                  ),
                  _buildTile(
                    emoji: '🔒',
                    title: 'Privacy',
                    subtitle: 'All data stays on your device',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Data'),
                  _buildTile(
                    emoji: '🗑️',
                    title: 'Clear All Data',
                    subtitle: 'Start fresh',
                    onTap: () => _confirmClear(context, provider),
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required String emoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isDestructive
                              ? AppColors.periodRed
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editName(BuildContext context, AppProvider provider) {
    final controller =
        TextEditingController(text: provider.profile.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Your Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updated = provider.profile
                  .copyWith(name: controller.text.trim());
              provider.saveProfile(updated);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editNumber(
    BuildContext context,
    String title,
    int current,
    void Function(int) onSave,
  ) {
    final controller =
        TextEditingController(text: '$current');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $title in days',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0 && val < 60) {
                onSave(val);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(
      BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('⚠️ Clear All Data'),
        content: const Text(
          'This will delete all your period logs, check-ins, and settings. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.periodRed,
            ),
            onPressed: () async {
              await provider.clearAllData();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}

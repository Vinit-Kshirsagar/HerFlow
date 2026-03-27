import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final tiles = _buildTileList(context, provider);
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', style: AppTypography.displaySmall),
                  const SizedBox(height: 24),
                  ...tiles,
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTileList(
      BuildContext context, AppProvider provider) {
    final sections = <Widget>[];
    int index = 0;

    Widget staggerItem(int i, Widget child) {
      final start = (i * 0.1).clamp(0.0, 0.7);
      final end = (start + 0.3).clamp(0.0, 1.0);
      final anim = CurvedAnimation(
        parent: _listController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
      return AnimatedBuilder(
        animation: anim,
        builder: (context, _) {
          return Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 18 * (1 - anim.value)),
              child: child,
            ),
          );
        },
      );
    }

    // ── Profile Section ──
    sections.add(staggerItem(index++, _sectionTitle('Profile')));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.person_rounded,
        iconColor: AppColors.secondary,
        title: provider.profile.name.isEmpty
            ? 'Set your name'
            : provider.profile.name,
        subtitle: 'Tap to edit',
        onTap: () => _editName(context, provider),
      ),
    ));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.loop_rounded,
        iconColor: AppColors.primary,
        title: 'Cycle Length',
        subtitle: '${provider.profile.cycleLength} days',
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
    ));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.water_drop_rounded,
        iconColor: AppColors.periodRed,
        title: 'Period Duration',
        subtitle: '${provider.profile.periodDuration} days',
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
    ));

    // ── About Section ──
    sections.add(const SizedBox(height: 24));
    sections.add(staggerItem(index++, _sectionTitle('About')));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.auto_awesome_rounded,
        iconColor: AppColors.secondary,
        title: 'HerFlow',
        subtitle: 'v1.0.0 — Made with love',
        onTap: () {},
      ),
    ));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.lock_rounded,
        iconColor: AppColors.accentDark,
        title: 'Privacy',
        subtitle: 'All data stays on your device',
        onTap: () {},
      ),
    ));

    // ── Data Section ──
    sections.add(const SizedBox(height: 24));
    sections.add(staggerItem(index++, _sectionTitle('Data')));
    sections.add(staggerItem(
      index++,
      _buildGlassTile(
        icon: Icons.delete_outline_rounded,
        iconColor: AppColors.error,
        title: 'Clear All Data',
        subtitle: 'Start fresh',
        onTap: () => _confirmClear(context, provider),
        isDestructive: true,
      ),
    ));

    return sections;
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelMedium.copyWith(
          color: AppColors.textMuted,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGlassTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: isDestructive
                ? AppColors.periodRed.withValues(alpha: 0.06)
                : AppColors.glassWhite,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDestructive
                        ? AppColors.periodRed.withValues(alpha: 0.2)
                        : AppColors.glassBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, size: 22, color: iconColor),
                    ),
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
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
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
                      Icons.chevron_right_rounded,
                      color: isDestructive
                          ? AppColors.periodRed.withValues(alpha: 0.5)
                          : AppColors.textMuted,
                      size: 22,
                    ),
                  ],
                ),
              ),
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
            borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.person_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 10),
            const Text('Your Name'),
          ],
        ),
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
    final controller = TextEditingController(text: '$current');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
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

  void _confirmClear(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 10),
            const Text('Clear All Data'),
          ],
        ),
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

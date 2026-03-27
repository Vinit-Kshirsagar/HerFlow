import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/enums.dart';
import '../core/constants/models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';
import 'main_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(provider),
                  const SizedBox(height: 24),
                  _buildLunaPhaseRing(context, provider),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, provider),
                  const SizedBox(height: 24),
                  _buildInsightCards(provider),
                  const SizedBox(height: 24),
                  if (!provider.hasCheckedInToday) _buildCheckInReminder(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider provider) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Good morning';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      emoji = '🌤️';
    } else {
      greeting = 'Good evening';
      emoji = '🌙';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting $emoji',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.profile.name.isNotEmpty
                  ? provider.profile.name
                  : 'Friend',
              style: AppTypography.displaySmall,
            ),
          ],
        ),
        // Streak badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${provider.profile.streak}',
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLunaPhaseRing(BuildContext context, AppProvider provider) {
    final phase = provider.currentPhase;
    final phaseColor = provider.getPhaseColor();
    final cycleDay = provider.cycleDay;
    final prediction = provider.prediction;
    final cycleLength = prediction?.predictedCycleLength ?? 28;
    final progress = cycleLength > 0
        ? (cycleDay / cycleLength).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            provider.getPhaseColorLight(),
            provider.getPhaseColorLight().withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Phase ring
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _PhaseRingPainter(
                      progress: progress,
                      color: phaseColor,
                      bgColor: phaseColor.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      phase.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Day $cycleDay',
                      style: AppTypography.displayMedium.copyWith(
                        color: phaseColor,
                      ),
                    ),
                    Text(
                      phase.label,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Luna insight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🌙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getLunaMessage(phase, provider),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (prediction != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  '${prediction.daysUntilNextPeriod} days until next period',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  prediction.confidence.emoji,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            emoji: '🩸',
            label: provider.activePeriod != null
                ? 'End Period'
                : 'Log Period',
            color: AppColors.periodRed,
            onTap: () {
              if (provider.activePeriod != null) {
                _endPeriod(context, provider);
              } else {
                _startPeriod(context, provider);
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            emoji: '💬',
            label: 'Check In',
            color: AppColors.primary,
            onTap: () {
              MainShellScope.of(context)?.navigateTo(2);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            emoji: '📊',
            label: 'Insights',
            color: AppColors.ovulationGreen,
            onTap: () {
              MainShellScope.of(context)?.navigateTo(1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCards(AppProvider provider) {
    final prediction = provider.prediction;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Cycle', style: AppTypography.headingMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                emoji: '📅',
                title: 'Cycle Length',
                value: prediction != null
                    ? '${prediction.predictedCycleLength} days'
                    : '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                emoji: '🩸',
                title: 'Period Duration',
                value: prediction != null
                    ? '${prediction.predictedPeriodDuration} days'
                    : '—',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInReminder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Check-in',
                  style: AppTypography.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'How are you feeling today?',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                MainShellScope.of(context)?.navigateTo(2);
              },
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLunaMessage(CyclePhase phase, AppProvider provider) {
    switch (phase) {
      case CyclePhase.period:
        return 'Take it easy today. Rest and self-care are your superpowers 💪';
      case CyclePhase.follicular:
        return 'Energy is building! Great time for new projects and socializing ✨';
      case CyclePhase.ovulation:
        return 'You\'re at peak energy! Your confidence is radiating 🌟';
      case CyclePhase.luteal:
        return 'Time to nest and reflect. Be gentle with yourself 🧡';
      case CyclePhase.unknown:
        return 'Log your period to get personalized insights! 🌙';
    }
  }

  void _startPeriod(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🩸 Log Period Start'),
        content: const Text('Starting your period today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.logPeriodStart(DateTime.now());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Yes, it started'),
          ),
        ],
      ),
    );
  }

  void _endPeriod(BuildContext context, AppProvider provider) {
    final active = provider.activePeriod;
    if (active == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('✅ Period Ended'),
        content: const Text('Has your period ended today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.logPeriodEnd(active.id, DateTime.now());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Yes, it ended'),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painter for Phase Ring ───
class _PhaseRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _PhaseRingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 12.0;

    // Background arc
    final bgPaint = Paint()
      ..color = bgColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Dot at current position
    final dotAngle = -math.pi / 2 + 2 * math.pi * progress;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 7, dotPaint);

    final dotBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(dotX, dotY), 5, dotBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _PhaseRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ─── Quick Action Card Widget ───
class _QuickActionCard extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(color: color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card Widget ───
class _StatCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;

  const _StatCard({
    required this.emoji,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.headingSmall),
        ],
      ),
    );
  }
}

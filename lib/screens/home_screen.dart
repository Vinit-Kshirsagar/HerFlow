import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/enums.dart';
import '../core/constants/models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';
import 'main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _ringController;

  late Animation<double> _headerAnim;
  late Animation<double> _ringAnim;
  late Animation<double> _actionsAnim;
  late Animation<double> _insightsAnim;
  late Animation<double> _reminderAnim;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );
    _ringAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
    );
    _actionsAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
    );
    _insightsAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
    );
    _reminderAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );

    _staggerController.forward();
    _ringController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnimatedSlide(_headerAnim,
                      child: _buildHeader(provider)),
                  const SizedBox(height: 24),
                  _buildAnimatedSlide(_ringAnim,
                      child: _buildLunaPhaseRing(context, provider)),
                  const SizedBox(height: 24),
                  _buildAnimatedSlide(_actionsAnim,
                      child: _buildQuickActions(context, provider)),
                  const SizedBox(height: 24),
                  _buildAnimatedSlide(_insightsAnim,
                      child: _buildInsightCards(provider)),
                  const SizedBox(height: 24),
                  if (!provider.hasCheckedInToday)
                    _buildAnimatedSlide(_reminderAnim,
                        child: _buildCheckInReminder(context)),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSlide(Animation<double> animation,
      {required Widget child}) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildHeader(AppProvider provider) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color greetingColor;
    if (hour < 12) {
      greeting = 'Good morning';
      greetingIcon = Icons.wb_sunny_rounded;
      greetingColor = const Color(0xFFFBBF24);
    } else if (hour < 17) {
      greeting = 'Good afternoon';
      greetingIcon = Icons.wb_cloudy_rounded;
      greetingColor = const Color(0xFFFB923C);
    } else {
      greeting = 'Good evening';
      greetingIcon = Icons.nightlight_round;
      greetingColor = AppColors.secondary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(greetingIcon, size: 18, color: greetingColor),
                const SizedBox(width: 6),
                Text(
                  greeting,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.12),
                AppColors.secondary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.local_fire_department_rounded,
                  size: 18, color: AppColors.primary),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            provider.getPhaseColorLight(),
            provider.getPhaseColorLight().withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: phaseColor.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated Phase ring
          SizedBox(
            width: 190,
            height: 190,
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _PhaseRingPainter(
                    progress: progress * _ringController.value,
                    color: phaseColor,
                    bgColor: phaseColor.withValues(alpha: 0.12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PhaseIcon(phase: phase, size: 38, color: phaseColor),
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
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Glassmorphic Luna insight card
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary.withValues(alpha: 0.15),
                            AppColors.primary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.auto_awesome_rounded,
                          size: 18, color: AppColors.secondary),
                    ),
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
            ),
          ),
          if (prediction != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.schedule_rounded,
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
                _ConfidenceDot(confidence: prediction.confidence),
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
            icon: provider.activePeriod != null
                ? Icons.stop_circle_outlined
                : Icons.water_drop_rounded,
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
            icon: Icons.edit_note_rounded,
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
            icon: Icons.insights_rounded,
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
                icon: Icons.loop_rounded,
                iconColor: AppColors.secondary,
                title: 'Cycle Length',
                value: prediction != null
                    ? '${prediction.predictedCycleLength} days'
                    : '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop_outlined,
                iconColor: AppColors.periodRed,
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite_rounded,
                size: 24, color: Colors.white),
          ),
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
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                MainShellScope.of(context)?.navigateTo(2);
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
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
        return 'Take it easy today. Rest and self-care are your superpowers.';
      case CyclePhase.follicular:
        return 'Energy is building! Great time for new projects and socializing.';
      case CyclePhase.ovulation:
        return 'You\'re at peak energy! Your confidence is radiating.';
      case CyclePhase.luteal:
        return 'Time to nest and reflect. Be gentle with yourself.';
      case CyclePhase.unknown:
        return 'Log your period to get personalized insights!';
    }
  }

  void _startPeriod(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.water_drop_rounded, color: AppColors.periodRed, size: 24),
            const SizedBox(width: 10),
            const Text('Log Period Start'),
          ],
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            const SizedBox(width: 10),
            const Text('Period Ended'),
          ],
        ),
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

// ─── Phase Icon (replaces emoji) ───
class _PhaseIcon extends StatelessWidget {
  final CyclePhase phase;
  final double size;
  final Color color;

  const _PhaseIcon({
    required this.phase,
    required this.size,
    required this.color,
  });

  IconData get _icon {
    switch (phase) {
      case CyclePhase.period:
        return Icons.water_drop_rounded;
      case CyclePhase.follicular:
        return Icons.eco_rounded;
      case CyclePhase.ovulation:
        return Icons.auto_awesome_rounded;
      case CyclePhase.luteal:
        return Icons.nightlight_round;
      case CyclePhase.unknown:
        return Icons.blur_circular_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(_icon, size: size * 0.55, color: color),
    );
  }
}

// ─── Confidence Dot (replaces emoji) ───
class _ConfidenceDot extends StatelessWidget {
  final PredictionConfidence confidence;
  const _ConfidenceDot({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: confidence.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: confidence.color.withValues(alpha: 0.4),
            blurRadius: 4,
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
    final radius = size.width / 2 - 12;
    const strokeWidth = 14.0;

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

    if (progress > 0) {
      final dotAngle = -math.pi / 2 + 2 * math.pi * progress;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(dotX, dotY), 10, glowPaint);

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 7, dotPaint);

      final dotBorderPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PhaseRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

// ─── Quick Action Card (with proper icons) ───
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, size: 22, color: widget.color),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: AppTypography.labelMedium.copyWith(
                  color: widget.color,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Stat Card (with icons) ───
class _StatCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: widget.iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11, // subtle reduction for cleaner label hierarchy
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: AppTypography.headingSmall.copyWith(
                  fontSize: 17, // slight bump for better readability
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
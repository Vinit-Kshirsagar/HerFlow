import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  DateTime? _lastPeriodDate;
  int _currentPage = 0;

  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your name'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _currentPage = 1);
    _fadeController.reset();
    _fadeController.forward();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.cardWhite,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _lastPeriodDate = picked);
    }
  }

  Future<void> _complete() async {
    if (_lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select your last period date'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final provider = context.read<AppProvider>();
    await provider.completeOnboarding(
      name: _nameController.text.trim(),
      lastPeriodDate: _lastPeriodDate!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(_fadeAnimation),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      2,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: i == _currentPage
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ],
                                )
                              : null,
                          color: i == _currentPage
                              ? null
                              : AppColors.primaryLighter,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Expanded(
                    child: _currentPage == 0
                        ? _buildNamePage()
                        : _buildDatePage(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLighter, Color(0xFFF3E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.nightlight_round,
                    size: 32, color: AppColors.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Hi, I\'m Luna!',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your cycle companion.\nLet\'s get to know each other.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.primaryDark.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        Text('What should I call you?', style: AppTypography.headingMedium),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Your name',
            prefixIcon:
                const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            filled: true,
            fillColor: AppColors.cardWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: _PulsingGradientButton(
            animation: _pulseController,
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            onTap: _nextPage,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePage() {
    final hasDate = _lastPeriodDate != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFCE4EC), Color(0xFFF3E8FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(Icons.favorite_rounded,
                    size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Nice to meet you, ${_nameController.text.trim()}!',
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'When did your last period start?\nThis helps me predict your cycle.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryDark.withValues(alpha: 0.8),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),
        GestureDetector(
          onTap: _selectDate,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasDate ? AppColors.primary : AppColors.border,
                width: hasDate ? 2 : 1,
              ),
              boxShadow: hasDate
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    hasDate
                        ? Icons.check_circle_rounded
                        : Icons.calendar_today_rounded,
                    key: ValueKey(hasDate),
                    color: hasDate
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  hasDate
                      ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
                      : 'Tap to select date',
                  style: hasDate
                      ? AppTypography.headingSmall.copyWith(
                          color: AppColors.primary)
                      : AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted),
                ),
                const Spacer(),
                if (!hasDate)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: AnimatedOpacity(
            opacity: hasDate ? 1.0 : 0.4,
            duration: const Duration(milliseconds: 300),
            child: _PulsingGradientButton(
              animation: hasDate ? _pulseController : null,
              label: 'Let\'s begin!',
              icon: Icons.arrow_forward_rounded,
              onTap: hasDate ? _complete : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Pulsing gradient CTA button
class _PulsingGradientButton extends StatelessWidget {
  final AnimationController? animation;
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _PulsingGradientButton({
    this.animation,
    required this.label,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTypography.button),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 20, color: Colors.white),
          ],
        ],
      ),
    );

    if (animation != null) {
      button = AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          final scale = 1.0 + (animation!.value * 0.02);
          return Transform.scale(scale: scale, child: child);
        },
        child: button,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: button,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/enums.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/app_provider.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen>
    with TickerProviderStateMixin {
  Mood? _selectedMood;
  final Set<Symptom> _selectedSymptoms = {};
  FlowLevel? _selectedFlow;
  final _noteController = TextEditingController();
  bool _submitted = false;

  late AnimationController _staggerController;
  late AnimationController _thankYouController;
  late Animation<double> _moodAnim;
  late Animation<double> _flowAnim;
  late Animation<double> _symptomAnim;
  late Animation<double> _notesAnim;
  late Animation<double> _buttonAnim;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _thankYouController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _moodAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
    );
    _flowAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOutCubic),
    );
    _symptomAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.3, 0.65, curve: Curves.easeOutCubic),
    );
    _notesAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
    );
    _buttonAnim = CurvedAnimation(
      parent: _staggerController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _noteController.dispose();
    _staggerController.dispose();
    _thankYouController.dispose();
    super.dispose();
  }

  Widget _slideIn(Animation<double> anim, {required Widget child}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: _submitted
              ? _buildThankYou(key: const ValueKey('thankyou'))
              : _buildForm(key: const ValueKey('form')),
        ),
      ),
    );
  }

  Widget _buildForm({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daily Check-in', style: AppTypography.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'How are you feeling today?',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.favorite_rounded,
                    size: 22, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Mood section
          _slideIn(_moodAnim, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.mood_rounded, 'Mood'),
              const SizedBox(height: 12),
              _buildMoodSelector(),
            ],
          )),
          const SizedBox(height: 28),

          // Flow section
          _slideIn(_flowAnim, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.water_drop_outlined, 'Flow'),
              const SizedBox(height: 12),
              _buildFlowSelector(),
            ],
          )),
          const SizedBox(height: 28),

          // Symptoms section
          _slideIn(_symptomAnim, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.monitor_heart_outlined, 'Symptoms'),
              const SizedBox(height: 12),
              _buildSymptomGrid(),
            ],
          )),
          const SizedBox(height: 28),

          // Notes
          _slideIn(_notesAnim, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(Icons.sticky_note_2_outlined, 'Notes'),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 3,
                style: AppTypography.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Anything you want to remember...',
                  filled: true,
                  fillColor: AppColors.cardWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          )),
          const SizedBox(height: 32),

          // Submit button
          _slideIn(_buttonAnim, child: SizedBox(
            width: double.infinity,
            child: _AnimatedGradientButton(
              label: 'Save Check-in',
              icon: Icons.check_circle_outline_rounded,
              enabled: _selectedMood != null,
              onTap: _submit,
            ),
          )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: AppTypography.headingSmall),
      ],
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Mood.values.map((mood) {
        final selected = _selectedMood == mood;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMood = mood),
            child: AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.cardWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(mood.emoji,
                        style: TextStyle(
                            fontSize: selected ? 30 : 26)),
                    const SizedBox(height: 4),
                    Text(
                      mood.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFlowSelector() {
    return Row(
      children: [
        Expanded(
          child: _FlowChip(
            label: 'None',
            icon: Icons.remove_circle_outline_rounded,
            selected: _selectedFlow == null,
            onTap: () => setState(() => _selectedFlow = null),
          ),
        ),
        ...FlowLevel.values.where((f) => f != FlowLevel.none).map((flow) {
          return Expanded(
            child: _FlowChip(
              label: flow.label,
              icon: Icons.water_drop_rounded,
              iconCount: flow.index,
              selected: _selectedFlow == flow,
              onTap: () => setState(() => _selectedFlow = flow),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSymptomGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Symptom.values.map((symptom) {
        final selected = _selectedSymptoms.contains(symptom);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selected) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
              }
            });
          },
          child: AnimatedScale(
            scale: selected ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border.withValues(alpha: 0.6),
                  width: selected ? 1.5 : 1,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color:
                              AppColors.primary.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _symptomIcon(symptom),
                    size: 16,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    symptom.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _symptomIcon(Symptom symptom) {
    switch (symptom) {
      case Symptom.cramps:
        return Icons.flash_on_rounded;
      case Symptom.headache:
        return Icons.psychology_rounded;
      case Symptom.backPain:
        return Icons.accessibility_new_rounded;
      case Symptom.acne:
        return Icons.face_rounded;
      case Symptom.breastTenderness:
        return Icons.healing_rounded;
      case Symptom.nausea:
        return Icons.sick_rounded;
      case Symptom.fatigue:
        return Icons.battery_1_bar_rounded;
      case Symptom.moodSwings:
        return Icons.swap_vert_rounded;
      case Symptom.cravings:
        return Icons.restaurant_rounded;
      case Symptom.insomnia:
        return Icons.bedtime_rounded;
    }
  }

  Future<void> _submit() async {
    if (_selectedMood == null) return;

    final provider = context.read<AppProvider>();
    await provider.saveCheckIn(
      mood: _selectedMood!,
      symptoms: _selectedSymptoms.toList(),
      flow: _selectedFlow,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() => _submitted = true);
    _thankYouController.forward(from: 0);
  }

  Widget _buildThankYou({Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.secondary.withValues(alpha: 0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                    size: 56, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 16 * (1 - value)),
                    child: Text(
                      'Check-in saved!',
                      style: AppTypography.displaySmall,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    _getLunaResponse(),
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _submitted = false;
                    _selectedMood = null;
                    _selectedSymptoms.clear();
                    _selectedFlow = null;
                    _noteController.clear();
                  });
                  _staggerController.forward(from: 0);
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit today\'s check-in'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLunaResponse() {
    switch (_selectedMood) {
      case Mood.great:
        return 'So glad you\'re feeling great today! Keep that energy going.';
      case Mood.good:
        return 'A good day is a great day! Enjoy the moment.';
      case Mood.okay:
        return 'It\'s okay to feel okay. Not every day has to be perfect.';
      case Mood.low:
        return 'Sending you warmth. Remember, tomorrow is a fresh start.';
      case Mood.bad:
        return 'Sorry you\'re having a tough day. Be extra gentle with yourself today.';
      default:
        return 'Thank you for checking in! See you tomorrow.';
    }
  }
}

// ─── Flow Chip (with icon) ───
class _FlowChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int iconCount;
  final bool selected;
  final VoidCallback onTap;

  const _FlowChip({
    required this.label,
    required this.icon,
    this.iconCount = 1,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.periodRed.withValues(alpha: 0.12)
                : AppColors.cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.periodRed
                  : AppColors.border.withValues(alpha: 0.6),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.periodRed.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  iconCount.clamp(1, 3),
                  (_) => Icon(
                    icon,
                    size: 14,
                    color: selected
                        ? AppColors.periodRed
                        : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: selected
                      ? AppColors.periodRed
                      : AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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

// ─── Animated Gradient Submit Button ───
class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool enabled;
  final VoidCallback onTap;

  const _AnimatedGradientButton({
    required this.label,
    this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTypography.button,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _CheckInScreenState extends State<CheckInScreen> {
  Mood? _selectedMood;
  final Set<Symptom> _selectedSymptoms = {};
  FlowLevel? _selectedFlow;
  final _noteController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _submitted ? _buildThankYou() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Check-in', style: AppTypography.displaySmall),
          const SizedBox(height: 4),
          Text(
            'How are you feeling today? 💕',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          // Mood section
          Text('Mood', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          _buildMoodSelector(),
          const SizedBox(height: 28),

          // Flow section
          Text('Flow', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          _buildFlowSelector(),
          const SizedBox(height: 28),

          // Symptoms section
          Text('Symptoms', style: AppTypography.headingSmall),
          const SizedBox(height: 12),
          _buildSymptomGrid(),
          const SizedBox(height: 28),

          // Notes
          Text('Notes', style: AppTypography.headingSmall),
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
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Submit
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedMood != null ? _submit : null,
              child: const Text('Save Check-in ✨'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Mood.values.map((mood) {
        final selected = _selectedMood == mood;
        return GestureDetector(
          onTap: () => setState(() => _selectedMood = mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 28)),
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
        );
      }).toList(),
    );
  }

  Widget _buildFlowSelector() {
    return Row(
      children: [
        // None option
        Expanded(
          child: _FlowChip(
            label: 'None',
            emoji: '○',
            selected: _selectedFlow == null,
            onTap: () => setState(() => _selectedFlow = null),
          ),
        ),
        ...FlowLevel.values.map((flow) {
          return Expanded(
            child: _FlowChip(
              label: flow.label,
              emoji: flow.emoji,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(symptom.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  symptom.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
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
  }

  Widget _buildThankYou() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Check-in saved!',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: 12),
            Text(
              _getLunaResponse(),
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                setState(() {
                  _submitted = false;
                  _selectedMood = null;
                  _selectedSymptoms.clear();
                  _selectedFlow = null;
                  _noteController.clear();
                });
              },
              child: const Text('Edit today\'s check-in'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLunaResponse() {
    switch (_selectedMood) {
      case Mood.great:
        return 'Yay! I\'m so glad you\'re feeling great today! Keep that energy going ✨';
      case Mood.good:
        return 'A good day is a great day! Enjoy the moment 🌸';
      case Mood.okay:
        return 'It\'s okay to feel okay. Not every day has to be perfect 💛';
      case Mood.low:
        return 'Sending you warmth. Remember, tomorrow is a fresh start 🤗';
      case Mood.bad:
        return 'I\'m sorry you\'re having a tough day. Be extra gentle with yourself today 💕';
      default:
        return 'Thank you for checking in! See you tomorrow 🌙';
    }
  }
}

class _FlowChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _FlowChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.periodRed.withValues(alpha: 0.12)
              : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.periodRed : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: selected
                    ? AppColors.periodRed
                    : AppColors.textSecondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

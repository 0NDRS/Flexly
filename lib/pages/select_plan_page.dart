import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/widgets/primary_button.dart';

class SelectPlanPage extends StatefulWidget {
  const SelectPlanPage({super.key});

  @override
  State<SelectPlanPage> createState() => _SelectPlanPageState();
}

class _SelectPlanPageState extends State<SelectPlanPage> {
  String? selectedGoal;

  final List<GoalOption> goals = [
    GoalOption(
      id: 'gain_muscles',
      title: 'Gain muscles',
      subtitle: 'Gain size & strength',
      icon: Icons.local_fire_department,
    ),
    GoalOption(
      id: 'loose_fat',
      title: 'Loose fat',
      subtitle: 'Shred & define',
      icon: Icons.local_fire_department,
    ),
    GoalOption(
      id: 'improve_endurance',
      title: 'Improve endurance',
      subtitle: 'Boost stamina',
      icon: Icons.local_fire_department,
    ),
    GoalOption(
      id: 'increase_flexibility',
      title: 'Increase flexibility',
      subtitle: 'Improve mobility',
      icon: Icons.local_fire_department,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with logo and text
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(34),
                              child: Image.asset(
                                'assets/icon/app_icon.png',
                                width: 100,
                                height: 100,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Tell us about\nyour goal',
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 28,
                                    color: AppColors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Powered by Flex Intelligence™',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.grayLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Goals List - Scrollable with Blur Effect
                  Stack(
                    children: [
                      SizedBox(
                        height: 280,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...goals.map((goal) => Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: _buildGoalOption(goal),
                                  )),
                              // Extra space to allow scrolling last item above blur
                              const SizedBox(height: 60),
                            ],
                          ),
                        ),
                      ),
                      // Blur overlay at the bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.backgroundDark
                                    .withValues(alpha: 0.95),
                                AppColors.backgroundDark,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Finish Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Finish',
                      onPressed: _handleFinish,
                      size: ButtonSize.large,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Skip Option at Bottom
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Prefer to do this later?',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.grayLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _handleSkip,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Skip',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '>',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoalOption(GoalOption goal) {
    final isSelected = selectedGoal == goal.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGoal = goal.id;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                goal.icon,
                color: AppColors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    goal.subtitle,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.grayLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleFinish() {
    // TODO: Save selected goal to backend
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  void _handleSkip() {
    // Navigate to home without saving goal
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}

class GoalOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;

  GoalOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class AnalysisStatsRow extends StatelessWidget {
  final int streak;
  final int tracked;
  final VoidCallback? onStreakTap;

  const AnalysisStatsRow({
    super.key,
    this.streak = 0,
    this.tracked = 0,
    this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onStreakTap,
            behavior: HitTestBehavior.opaque,
            child: _buildStatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppColors.fireOrange,
              label: 'Streak',
              value: '$streak days',
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.fitness_center_rounded,
            iconColor: AppColors.waterBlue,
            label: 'Tracked',
            value: '$tracked',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption2
                      .copyWith(color: AppColors.grayLight),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

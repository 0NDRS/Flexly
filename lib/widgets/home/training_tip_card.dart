import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class TrainingTipCard extends StatelessWidget {
  final Map<String, dynamic>? latestTrainingPlan;
  final VoidCallback? onTap;

  const TrainingTipCard({
    super.key,
    this.latestTrainingPlan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = latestTrainingPlan != null;
    final tips = hasData ? (latestTrainingPlan!['tips'] as List?) : null;
    final hasTips = tips != null && tips.isNotEmpty;

    final title = hasData
        ? (latestTrainingPlan!['title'] ?? 'Training Plan')
        : 'No Training Plan Yet';
    final subtitle = hasTips
        ? tips.first.toString()
        : (hasData
            ? latestTrainingPlan!['description'] ??
                'View your personalized training plan'
            : 'Generate a personalized training plan to get tips.');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.fireBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              size: 12,
                              color: AppColors.fireOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pro Tip',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.fireOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body2
                        .copyWith(color: AppColors.grayLight, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grayLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

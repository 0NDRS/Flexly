import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class TrainingTipCard extends StatelessWidget {
  final Map<String, dynamic>? latestAnalysis;
  final VoidCallback? onTap;

  const TrainingTipCard({
    super.key,
    this.latestAnalysis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = latestAnalysis != null && latestAnalysis!['advice'] != null;
    final title =
        hasData ? (latestAnalysis!['adviceTitle'] ?? 'New Tip') : 'No Tips Yet';
    final subtitle = hasData
        ? latestAnalysis!['advice']
        : 'Analyze your physique to get personalized training tips.';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.grayLight,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Training Tip',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTextStyles.body2
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.small
                        .copyWith(color: AppColors.grayLight),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
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

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/data/mock_data.dart';

class HistoryCard extends StatelessWidget {
  final String date;
  final double overallRating;
  final Map<String, double> bodyPartRatings;
  final VoidCallback? onDetailsTap;
  final String? imageUrl;

  const HistoryCard({
    super.key,
    required this.date,
    required this.overallRating,
    required this.bodyPartRatings,
    this.onDetailsTap,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: AppTextStyles.body1.copyWith(color: AppColors.white),
              ),
              GestureDetector(
                onTap: onDetailsTap,
                child: Text(
                  'See Details',
                  style:
                      AppTextStyles.caption2.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: onDetailsTap,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image:
                          NetworkImage(imageUrl ?? MockData.placeholderImage),
                      fit: BoxFit.cover,
                      opacity: imageUrl != null ? 1.0 : 0.08,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Open analysis',
                          style: AppTextStyles.caption2
                              .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Rating:',
                style: AppTextStyles.h3,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: overallRating.toString(),
                      style: AppTextStyles.h2.copyWith(fontSize: 32),
                    ),
                    TextSpan(
                      text: ' / 10',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.grayLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: AppColors.gray, height: 1),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Arms', bodyPartRatings['Arms'] ?? 0),
                    const SizedBox(height: 12),
                    _buildStatRow('Abs', bodyPartRatings['Abs'] ?? 0),
                    const SizedBox(height: 12),
                    _buildStatRow('Legs', bodyPartRatings['Legs'] ?? 0),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Chest', bodyPartRatings['Chest'] ?? 0),
                    const SizedBox(height: 12),
                    _buildStatRow(
                        'Shoulders', bodyPartRatings['Shoulders'] ?? 0),
                    const SizedBox(height: 12),
                    _buildStatRow('Back', bodyPartRatings['Back'] ?? 0),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    final isVisible = value > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.body2.copyWith(color: AppColors.white),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isVisible ? value.toString() : '-',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isVisible)
                TextSpan(
                  text: '/10',
                  style: AppTextStyles.caption1
                      .copyWith(color: AppColors.grayLight),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

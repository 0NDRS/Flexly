import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/primary_button.dart';

class AnalysisCard extends StatelessWidget {
  final double rating;
  final String date;
  final int streak;
  final int tracked;
  final String? imageUrl;
  final VoidCallback? onDetailsTap;
  final VoidCallback? onUploadTap;
  final VoidCallback? onStreakTap;

  const AnalysisCard({
    super.key,
    required this.rating,
    required this.date,
    this.streak = 0,
    this.tracked = 0,
    this.imageUrl,
    this.onDetailsTap,
    this.onUploadTap,
    this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray, width: 1),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildRatingSection(),
          const SizedBox(height: 24),
          _buildStatsRow(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Upload New',
              onPressed: onUploadTap ?? () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Stats',
              style: AppTextStyles.caption2.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: AppTextStyles.small.copyWith(color: AppColors.white),
            ),
          ],
        ),
        GestureDetector(
          onTap: onDetailsTap,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Text(
                'See Details',
                style:
                    AppTextStyles.caption2.copyWith(color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onDetailsTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(20),
                child: imageUrl == null
                    ? Center(
                        child: Icon(
                          Icons.bar_chart,
                          size: 72,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
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
        Text(
          'Overall Rating',
          style: AppTextStyles.small.copyWith(color: AppColors.grayLight),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: rating.toStringAsFixed(1),
                style: AppTextStyles.h1.copyWith(fontSize: 44),
              ),
              TextSpan(
                text: ' /10',
                style: AppTextStyles.h3.copyWith(color: AppColors.grayLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onStreakTap,
              behavior: HitTestBehavior.opaque,
              child: _buildStatItem(
                icon: Icons.local_fire_department,
                iconColor: AppColors.fireOrange,
                iconBgColor: AppColors.fireBackground,
                label: 'Streak',
                value: '$streak days',
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 32,
            color: AppColors.grayLight.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              icon: Icons.analytics_outlined,
              iconColor: AppColors.waterBlue,
              iconBgColor: AppColors.waterBackground,
              label: 'Analyses',
              value: '$tracked',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(color: AppColors.grayLight),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style:
                    AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

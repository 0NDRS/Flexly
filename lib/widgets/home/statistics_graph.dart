import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class StatisticsGraph extends StatelessWidget {
  const StatisticsGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('Mon', 0.4, false),
                _buildBar('Tue', 0.6, false),
                _buildBar('Wed', 0.3, false),
                _buildBar('Thu', 0.8, true),
                _buildBar('Fri', 0.5, false),
                _buildBar('Sat', 0.2, false),
                _buildBar('Sun', 0.4, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightFactor, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.gray,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: AppTextStyles.small.copyWith(
            color: isSelected ? AppColors.white : AppColors.grayLight,
          ),
        ),
      ],
    );
  }
}

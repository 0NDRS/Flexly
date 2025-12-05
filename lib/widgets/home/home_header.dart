import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/data/mock_data.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grayLight, // Placeholder for profile image
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hi, ${MockData.userName} 👋',
              style: AppTextStyles.caption1.copyWith(color: AppColors.white),
            ),
            Text(
              "Let's workout!",
              style: AppTextStyles.small.copyWith(color: AppColors.white),
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grayDark,
            border: Border.all(color: AppColors.gray, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: 0,
                child: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              Positioned(
                top: 14,
                right: 16,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

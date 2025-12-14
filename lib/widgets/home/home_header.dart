import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/data/mock_data.dart';
import 'package:flexly/pages/home.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  void _navigateToProfile(BuildContext context) {
    // Find the HomePage in the widget tree and navigate to profile tab
    if (context.findAncestorWidgetOfExactType<HomePage>() != null) {
      // Since we're inside HomePage which has IndexedStack with tab navigation,
      // we need to find the state and call onTabChange
      // Alternative: Use named routes or Provider pattern
      // For now, we'll use a simple approach by going to home and then to profile
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      // Then trigger profile tab
      Future.delayed(const Duration(milliseconds: 100), () {
        // This will be handled by the HomePage itself
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to profile page by changing the tab in HomePage
            // We'll use a more elegant solution with Provider/GetX, but for now:
            // Navigate to home and pass index to show profile
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialIndex: 4),
              ),
            );
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayLight, // Placeholder for profile image
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(initialIndex: 4),
              ),
            );
          },
          child: Column(
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

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/register_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Header
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
                            width: 120,
                            height: 120,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your body\nkeeps score',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28,
                                color: AppColors.white,
                                height: 1.2,
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Make it count.',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28,
                                color: AppColors.white,
                                height: 1.2,
                              ),
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
              // Carousel - Scrollable in middle
              SizedBox(
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: const [
                      _SplashCard2(),
                      _SplashCard3(),
                      _SplashCard4(),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Bottom Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.white
                              : AppColors.grayLight.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Get Started' : 'Next',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashCard2 extends StatelessWidget {
  const _SplashCard2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon placeholder with heart shape
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayDark,
            ),
            child: const Center(
              child: Icon(
                Icons.favorite,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Real-time\nTracking',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Track your progress\nin real time',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.grayLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashCard3 extends StatelessWidget {
  const _SplashCard3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon placeholder with flame shape
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayDark,
            ),
            child: const Center(
              child: Icon(
                Icons.local_fire_department,
                size: 50,
                color: AppColors.fireOrange,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'AI Physique\nScoring',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'See real progress\nnot guesses',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.grayLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashCard4 extends StatelessWidget {
  const _SplashCard4();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon placeholder with settings shape
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayDark,
            ),
            child: const Center(
              child: Icon(
                Icons.settings,
                size: 50,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Personalized\nFeatures',
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 36,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Customize your experience\nto reach your goals',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.grayLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

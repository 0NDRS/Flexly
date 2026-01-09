import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/data/mock_data.dart';

class AnalysisDetailPage extends StatefulWidget {
  final String date;
  final double overallRating;
  final Map<String, double> bodyPartRatings;
  final String adviceTitle;
  final String adviceDescription;
  final List<String> imageUrls;
  final bool isMe;

  const AnalysisDetailPage({
    super.key,
    required this.date,
    required this.overallRating,
    required this.bodyPartRatings,
    this.adviceTitle = MockData.adviceTitle,
    this.adviceDescription = MockData.adviceDescription,
    this.imageUrls = const [],
    this.isMe = true,
  });

  @override
  State<AnalysisDetailPage> createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Dynamically prepare stats
    final statsEntries = widget.bodyPartRatings.entries.toList();
    // Sort if needed, or rely on map order.
    // Split into two columns
    final mid = (statsEntries.length / 2).ceil();
    final leftStats = statsEntries.take(mid).toList();
    final rightStats = statsEntries.skip(mid).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.pop(context),
                        ),
                        // Removed settings button, placeholder for alignment if needed or just empty
                        const SizedBox(width: 48),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          widget.date,
                          style:
                              AppTextStyles.h2.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: widget.isMe
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.grayLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: widget.isMe
                                    ? AppColors.primary
                                    : AppColors.grayLight,
                                width: 0.5),
                          ),
                          child: Text(
                            widget.isMe ? 'My Post' : "Other's Post",
                            style: AppTextStyles.small.copyWith(
                              color: widget.isMe
                                  ? AppColors.primary
                                  : AppColors.grayLight,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Image Carousel
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: widget.imageUrls.isEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            MockData.placeholderImage,
                            fit: BoxFit.cover,
                            opacity: const AlwaysStoppedAnimation(0.1),
                          ),
                        )
                      : Stack(
                          children: [
                            PageView.builder(
                              itemCount: widget.imageUrls.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    widget.imageUrls[index],
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                            if (widget.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    widget.imageUrls.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _currentImageIndex == index
                                            ? AppColors.primary
                                            : AppColors.white
                                                .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                // Analysis Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analysis:',
                      style: AppTextStyles.h2,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.overallRating.toString(),
                            style: AppTextStyles.h1.copyWith(fontSize: 40),
                          ),
                          TextSpan(
                            text: ' / 10',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.grayLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Stats Grid
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: leftStats
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildStatRow(
                                        _capitalize(e.key), e.value),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 24),
                      if (rightStats.isNotEmpty) ...[
                        Container(
                          width: 1,
                          height: (rightStats.length * 40)
                              .toDouble(), // Approximate height
                          color: AppColors.gray,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: rightStats
                                .map((e) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: _buildStatRow(
                                          _capitalize(e.key), e.value),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Advice Section
                Text(
                  'Advice:',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.adviceTitle,
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.adviceDescription,
                        style: AppTextStyles.body1
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.grayDark,
          border: Border.all(color: AppColors.gray, width: 1),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 20,
        ),
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

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

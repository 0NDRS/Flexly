import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/analysis/analysis_stats_row.dart';
import 'package:flexly/widgets/analysis/history_card.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/data/mock_data.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

  void _navigateToDetails(
    BuildContext context,
    String date,
    double overallRating,
    Map<String, double> bodyPartRatings,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailPage(
          date: date,
          overallRating: overallRating,
          bodyPartRatings: bodyPartRatings,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const HomeHeader(),
              const SizedBox(height: 24),
              // Upload New Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Upload New',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const AnalysisStatsRow(),
              const SizedBox(height: 32),
              Text(
                'History',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final dates = ['30.10.2025', '29.10.2025', '28.10.2025'];
                  final ratings = [7.8, 8.1, 7.5];

                  return HistoryCard(
                    date: dates[index],
                    overallRating: ratings[index],
                    bodyPartRatings: MockData.bodyPartRatings,
                    onDetailsTap: () => _navigateToDetails(
                      context,
                      dates[index],
                      ratings[index],
                      MockData.bodyPartRatings,
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

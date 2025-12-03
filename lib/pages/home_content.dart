import 'package:flutter/material.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/section_header.dart';
import 'package:flexly/widgets/home/analysis_card.dart';
import 'package:flexly/widgets/home/statistics_graph.dart';
import 'package:flexly/widgets/home/training_tip_card.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/data/mock_data.dart';

class HomeContent extends StatelessWidget {
  final Function(int) onTabChange;

  const HomeContent({
    super.key,
    required this.onTabChange,
  });

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalysisDetailPage(
          date: '30.10.2025',
          overallRating: 7.8,
          bodyPartRatings: MockData.bodyPartRatings,
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
              const SizedBox(height: 32),
              SectionHeader(
                title: 'Analysis',
                actionText: 'View All',
                onActionTap: () => onTabChange(2),
              ),
              const SizedBox(height: 16),
              AnalysisCard(
                onDetailsTap: () => _navigateToDetails(context),
              ),
              const SizedBox(height: 32),
              SectionHeader(
                title: 'Statistics',
                actionText: 'View All',
                onActionTap: () => onTabChange(3),
              ),
              const SizedBox(height: 16),
              const StatisticsGraph(),
              const SizedBox(height: 32),
              SectionHeader(
                title: 'Training Tips',
                actionText: 'View All',
                onActionTap: () => onTabChange(1),
              ),
              const SizedBox(height: 16),
              const TrainingTipCard(),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

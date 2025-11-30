import 'package:flutter/material.dart';
import 'package:flexly/widgets/app_bottom_navigation_bar.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/section_header.dart';
import 'package:flexly/widgets/home/analysis_card.dart';
import 'package:flexly/widgets/home/statistics_graph.dart';
import 'package:flexly/widgets/home/training_tip_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                HomeHeader(),
                SizedBox(height: 32),
                SectionHeader(
                  title: 'Analysis',
                  actionText: 'View All',
                ),
                SizedBox(height: 16),
                AnalysisCard(),
                SizedBox(height: 32),
                SectionHeader(
                  title: 'Statistics',
                  actionText: 'View All',
                ),
                SizedBox(height: 16),
                StatisticsGraph(),
                SizedBox(height: 32),
                SectionHeader(
                  title: 'Training Tips',
                  actionText: 'View All',
                ),
                SizedBox(height: 16),
                TrainingTipCard(),
                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

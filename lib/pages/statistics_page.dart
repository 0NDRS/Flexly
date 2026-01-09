import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  HomeHeader(),
                  SizedBox(
                      height:
                          10), // Reduced space slightly because TabBar has its own padding
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grayLight,
              labelStyle: AppTextStyles.button2,
              dividerColor: Colors.transparent, // Fixes white line
              tabs: const [
                Tab(text: 'Statistics'),
                Tab(text: 'Leaderboard'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  StatisticsTab(),
                  LeaderboardTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  final _analysisService = AnalysisService();
  bool _isLoading = true;
  List<dynamic> _analyses = [];
  Map<String, double> _averageMuscleRatings = {};
  double _overallAverage = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final analyses = await _analysisService.getAnalyses();

      // Calculate stats
      if (analyses.isNotEmpty) {
        double totalOverall = 0;
        int validOverallCount = 0;
        Map<String, List<double>> muscleRatings = {};

        for (var analysis in analyses) {
          final ratings = analysis['ratings'] as Map<String, dynamic>;

          if (ratings.containsKey('overall')) {
            final double val = (ratings['overall'] as num).toDouble();
            if (val > 0) {
              totalOverall += val;
              validOverallCount++;
            }
          }

          ratings.forEach((key, value) {
            if (key != 'overall' && value is num) {
              if (value > 0) {
                if (!muscleRatings.containsKey(key)) {
                  muscleRatings[key] = [];
                }
                muscleRatings[key]!.add(value.toDouble());
              }
            }
          });
        }

        final averageMuscleRatings = <String, double>{};
        muscleRatings.forEach((key, values) {
          if (values.isNotEmpty) {
            final avg = values.reduce((a, b) => a + b) / values.length;
            averageMuscleRatings[key] = avg;
          }
        });

        if (mounted) {
          setState(() {
            _analyses = analyses;
            _overallAverage =
                validOverallCount > 0 ? totalOverall / validOverallCount : 0;
            _averageMuscleRatings = averageMuscleRatings;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_analyses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined,
                size: 64, color: AppColors.grayLight),
            const SizedBox(height: 16),
            Text(
              'No statistics available yet',
              style: AppTextStyles.body1.copyWith(color: AppColors.grayLight),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your first analysis to see stats',
              style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
            ),
            const SizedBox(height: 24),
            // PrimaryButton needs to be imported if you want to use it, or just use elevated button style
            ElevatedButton(
              onPressed: () {
                // Navigate to analysis page (index 2 in main navigation)
                // Since navigateToTab is not passed here, we might need to handle it differently
                // or just let user navigate manually.
                // For now, let's fix the "empty button" issue by making it a proper text
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30))),
              child: const Text('Start Analysis'),
            ),
          ],
        ),
      );
    }

    // Prepare chart spots
    final List<FlSpot> spots = [];
    final reversedAnalyses = _analyses.reversed.toList(); // Oldest first
    for (int i = 0; i < reversedAnalyses.length; i++) {
      final ratings = reversedAnalyses[i]['ratings'] as Map<String, dynamic>;
      final overall = (ratings['overall'] as num).toDouble();

      // Skip 0 ratings (not analyzed/visible)
      if (overall <= 0) continue;

      // Take only last 10 for clarity if too many
      if (reversedAnalyses.length > 10 && i < reversedAnalyses.length - 10) {
        continue;
      }

      spots.add(FlSpot(i.toDouble(), overall));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${AnalysisService.calculateStreak(_analyses)} days',
                  Icons.local_fire_department,
                  AppColors.fireOrange,
                  bgColor: AppColors.fireBackground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Analyses',
                  _analyses.length.toString(),
                  Icons.analytics_outlined,
                  AppColors.waterBlue,
                  bgColor: AppColors.waterBackground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Avg. Score',
                  _overallAverage.toStringAsFixed(1),
                  Icons.star,
                  Colors.yellow,
                  bgColor: Colors.yellow.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Chart
          Text('Progress Trend', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Container(
            height: 200,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.only(top: 10, bottom: 0),
            decoration: BoxDecoration(
              color: AppColors.grayDark,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: spots.isNotEmpty ? spots.first.x : 0,
                maxX: spots.isNotEmpty && spots.length > 1
                    ? spots.last.x
                    : (spots.isNotEmpty ? spots.first.x + 1 : 1),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Muscle Group Performance
          Text('Weakest Points', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ..._buildMuscleBreakdown(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor ?? color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.body2
                .copyWith(color: AppColors.grayLight, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            value,
            style: AppTextStyles.h3
                .copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMuscleBreakdown() {
    final sortedEntries = _averageMuscleRatings.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // Weakest first

    return sortedEntries.take(5).map((e) {
      final name = e.key[0].toUpperCase() + e.key.substring(1);
      final score = e.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(name, style: AppTextStyles.body1),
            ),
            Container(
              width: 80,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.gray,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (score / 10).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: _getColorForScore(score),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 30,
              child: Text(
                score.toStringAsFixed(1),
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getColorForScore(score),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Color _getColorForScore(double score) {
    if (score >= 8) return const Color(0xFF4CAF50); // Green
    if (score >= 5) return Colors.yellow;
    return AppColors.primary; // Red
  }
}

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.leaderboard,
              size: 64, color: AppColors.grayLight.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Leaderboard Coming Soon',
            style: AppTextStyles.h3.copyWith(color: AppColors.grayLight),
          ),
          const SizedBox(height: 8),
          Text(
            'Compete with others based on your\nanalysis score and streaks!',
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
          ),
        ],
      ),
    );
  }
}

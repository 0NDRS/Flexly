import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/section_header.dart';
import 'package:flexly/widgets/home/analysis_card.dart';
import 'package:flexly/widgets/home/statistics_graph.dart';
import 'package:flexly/widgets/home/training_tip_card.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/pages/analysis_loading_page.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class HomeContent extends StatefulWidget {
  final Function(int) onTabChange;

  const HomeContent({
    super.key,
    required this.onTabChange,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> _analyses = [];
  Map<String, dynamic>? _latestAnalysis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestAnalysis();
  }

  Future<void> _fetchLatestAnalysis() async {
    try {
      final service = AnalysisService();
      final analyses = await service.getAnalyses();
      if (mounted) {
        setState(() {
          _analyses = analyses;
          if (analyses.isNotEmpty) {
            _latestAnalysis = analyses.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Silently fail or show a small error indicator if needed
        debugPrint('Error fetching latest analysis: $e');
      }
    }
  }

  void _navigateToDetails(BuildContext context) {
    if (_latestAnalysis == null) return;

    final analysis = _latestAnalysis!;
    final dateStr = analysis['createdAt'];
    final date = DateTime.parse(dateStr);
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    final ratings = analysis['ratings'];
    final overall = (ratings['overall'] as num).toDouble();

    final Map<String, double> bodyPartRatings = {
      'Arms': (ratings['arms'] as num).toDouble(),
      'Chest': (ratings['chest'] as num).toDouble(),
      'Abs': (ratings['abs'] as num).toDouble(),
      'Shoulders': (ratings['shoulders'] as num).toDouble(),
      'Legs': (ratings['legs'] as num).toDouble(),
      'Back': (ratings['back'] as num).toDouble(),
    };

    List<String> imageUrls = [];
    if (analysis['imageUrls'] != null) {
      imageUrls = (analysis['imageUrls'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailPage(
          date: formattedDate,
          overallRating: overall,
          bodyPartRatings: bodyPartRatings,
          adviceDescription: analysis['advice'] ?? '',
          imageUrls: imageUrls,
          adviceTitle: analysis['adviceTitle'] ?? 'Analysis Result',
        ),
      ),
    );
  }

  void _handleUpload(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalysisLoadingPage()),
    );
    _fetchLatestAnalysis();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchLatestAnalysis,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const HomeHeader(),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Analysis',
                  actionText: 'View All',
                  onActionTap: () => widget.onTabChange(2),
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_latestAnalysis != null)
                  AnalysisCard(
                    rating: (_latestAnalysis!['ratings']['overall'] as num)
                        .toDouble(),
                    date: DateFormat('dd.MM.yyyy')
                        .format(DateTime.parse(_latestAnalysis!['createdAt'])),
                    streak: AnalysisService.calculateStreak(_analyses),
                    tracked: _analyses.length,
                    imageUrl: (_latestAnalysis!['imageUrls'] != null &&
                            (_latestAnalysis!['imageUrls'] as List).isNotEmpty)
                        ? _latestAnalysis!['imageUrls'][0]
                        : null,
                    onDetailsTap: () => _navigateToDetails(context),
                    onUploadTap: () => _handleUpload(context),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.grayDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.gray),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            'No analysis yet',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.white),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _handleUpload(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Start First Analysis'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Statistics',
                  actionText: 'View All',
                  onActionTap: () => widget.onTabChange(3),
                ),
                const SizedBox(height: 16),
                StatisticsGraph(analyses: _analyses),
                const SizedBox(height: 32),
                SectionHeader(
                  title: 'Training Tips',
                  actionText: 'View All',
                  onActionTap: () => widget.onTabChange(2),
                ),
                const SizedBox(height: 16),
                TrainingTipCard(
                  latestAnalysis: _latestAnalysis,
                  onTap: () {
                    if (_latestAnalysis == null) {
                      _handleUpload(context);
                    } else {
                      _navigateToDetails(context);
                    }
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

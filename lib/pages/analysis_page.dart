import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/analysis/analysis_stats_row.dart';
import 'package:flexly/widgets/analysis/history_card.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/pages/analysis_loading_page.dart';
import 'package:flexly/services/analysis_service.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<dynamic> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyses();
  }

  Future<void> _fetchAnalyses() async {
    try {
      final service = AnalysisService();
      final data = await service.getAnalyses();
      if (mounted) {
        setState(() {
          _analyses = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading history: $e')),
        );
      }
    }
  }

  void _handleUpload(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AnalysisLoadingPage()),
    );
    // Refresh list after returning from upload
    _fetchAnalyses();
  }

  void _navigateToDetails(
    BuildContext context,
    String date,
    double overallRating,
    Map<String, double> bodyPartRatings,
    String advice,
    List<String> imageUrls,
    String adviceTitle,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailPage(
          date: date,
          overallRating: overallRating,
          bodyPartRatings: bodyPartRatings,
          adviceDescription: advice,
          imageUrls: imageUrls,
          adviceTitle: adviceTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _fetchAnalyses,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    onPressed: () => _handleUpload(context),
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
                AnalysisStatsRow(
                  streak: AnalysisService.calculateStreak(_analyses),
                  tracked: _analyses.length,
                ),
                const SizedBox(height: 32),
                Text(
                  'History',
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_analyses.isEmpty)
                  Center(
                    child: Text(
                      'No analysis history yet',
                      style: AppTextStyles.body1
                          .copyWith(color: AppColors.grayLight),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _analyses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final analysis = _analyses[index];
                      final dateStr = analysis['createdAt'];
                      final date = DateTime.parse(dateStr);
                      final formattedDate =
                          DateFormat('dd.MM.yyyy').format(date);

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

                      final String? imageUrl = (analysis['imageUrls'] != null &&
                              (analysis['imageUrls'] as List).isNotEmpty)
                          ? analysis['imageUrls'][0]
                          : null;

                      final List<String> imageUrls =
                          (analysis['imageUrls'] as List<dynamic>?)
                                  ?.map((e) => e.toString())
                                  .toList() ??
                              [];

                      return HistoryCard(
                        date: formattedDate,
                        overallRating: overall,
                        bodyPartRatings: bodyPartRatings,
                        imageUrl: imageUrl,
                        onDetailsTap: () => _navigateToDetails(
                          context,
                          formattedDate,
                          overall,
                          bodyPartRatings,
                          analysis['advice'] ?? '',
                          imageUrls,
                          analysis['adviceTitle'] ?? 'Analysis Result',
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

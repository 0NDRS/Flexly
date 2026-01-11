import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class StreakPage extends StatefulWidget {
  final List<dynamic>? initialAnalyses;

  const StreakPage({super.key, this.initialAnalyses});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  final _analysisService = AnalysisService();
  List<dynamic> _analyses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnalyses != null) {
      _analyses = List<dynamic>.from(widget.initialAnalyses!);
      _isLoading = false;
    } else {
      _fetchAnalyses();
    }
  }

  Set<DateTime> get _analysisDays {
    return _analyses
        .map((a) => DateTime.parse(a['createdAt']))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet();
  }

  int get _currentStreak => AnalysisService.calculateStreak(_analyses);

  int get _longestStreak {
    final dates = _analysisDays.toList()..sort();
    if (dates.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
      } else {
        longest = current > longest ? current : longest;
        current = 1;
      }
    }

    longest = current > longest ? current : longest;
    return longest;
  }

  Future<void> _fetchAnalyses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _analysisService.getAnalyses(page: 1, limit: 100);
      if (!mounted) return;
      setState(() {
        _analyses = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load streak data';
      });
    }
  }

  List<_DayStatus> get _recentDays {
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final days = <_DayStatus>[];

    for (int i = 0; i < 7; i++) {
      final date = normalizedToday.subtract(Duration(days: i));
      days.add(
        _DayStatus(
          label: DateFormat('EEE').format(date),
          date: date,
          isDone: _analysisDays.contains(date),
        ),
      );
    }

    return days.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.backgroundDark,
        iconTheme: IconThemeData(color: AppColors.white),
        title: Text(
          'Streaks',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAnalyses,
          child: _isLoading
              ? ListView(
                  children: const [
                    SizedBox(
                      height: 320,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _error!,
                            style: AppTextStyles.body2
                                .copyWith(color: Colors.redAccent),
                          ),
                        ),
                      _buildHeroCard(),
                      const SizedBox(height: 16),
                      _buildActivityCard(),
                      const SizedBox(height: 16),
                      _buildGuidanceCard(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keep the fire going',
            style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatTile(
                  title: 'Current',
                  value: '$_currentStreak days',
                  icon: Icons.local_fire_department,
                  iconColor: AppColors.fireOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatTile(
                  title: 'Longest',
                  value: '$_longestStreak days',
                  icon: Icons.flag_outlined,
                  iconColor: AppColors.waterBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatTile(
            title: 'Analyses logged',
            value: _analyses.length.toString(),
            icon: Icons.analytics_outlined,
            iconColor: AppColors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: AppColors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'Recent activity',
                style: AppTextStyles.body1.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentDays
                .map(
                  (day) => _DayChip(
                    label: day.label,
                    isDone: day.isDone,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Streak guidance',
                style: AppTextStyles.body1.copyWith(color: AppColors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip(
            'Log once per day',
            'One upload every day keeps your streak alive.',
          ),
          const SizedBox(height: 10),
          _buildTip(
            'Batch images work',
            'Upload multiple angles at once to reduce friction.',
          ),
          const SizedBox(height: 10),
          _buildTip(
            'Reset intentionally',
            'If you miss a day, start a new streak the next morning.',
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.caption2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.body1.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayStatus {
  final String label;
  final DateTime date;
  final bool isDone;

  _DayStatus({
    required this.label,
    required this.date,
    required this.isDone,
  });
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isDone;

  const _DayChip({
    required this.label,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDone
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone
              ? AppColors.primary.withValues(alpha: 0.5)
              : AppColors.gray.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? AppColors.primary : AppColors.grayLight,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.caption1.copyWith(
              color: isDone ? AppColors.white : AppColors.grayLight,
            ),
          ),
        ],
      ),
    );
  }
}

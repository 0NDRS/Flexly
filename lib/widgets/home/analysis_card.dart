import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/primary_button.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class AnalysisCard extends StatefulWidget {
  final VoidCallback? onDetailsTap;

  const AnalysisCard({
    super.key,
    this.onDetailsTap,
  });

  @override
  State<AnalysisCard> createState() => _AnalysisCardState();
}

class _AnalysisCardState extends State<AnalysisCard> {
  Future<Map<String, dynamic>>? _analysisData;

  @override
  void initState() {
    super.initState();
    _analysisData = _fetchAnalysisData();
  }

  Future<Map<String, dynamic>> _fetchAnalysisData() async {
    final String baseUrl =
        Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/analysis'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load analysis data');
      }
    } catch (e) {
      // Fallback data for UI demonstration
      return {
        'rating': 7.8,
        'streak': 10,
        'analyticsTracked': 84,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _analysisData,
      builder: (context, snapshot) {
        final data = snapshot.data ??
            {
              'rating': 7.8,
              'streak': 10,
              'analyticsTracked': 84,
            };

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.grayDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.gray, width: 1),
          ),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildRatingSection(data['rating']),
              const SizedBox(height: 24),
              _buildStatsRow(data['streak'], data['analyticsTracked']),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Upload New',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest Stats',
              style: AppTextStyles.caption2.copyWith(color: AppColors.white),
            ),
            Text(
              '30.10.2025',
              style: AppTextStyles.small.copyWith(color: AppColors.white),
            ),
          ],
        ),
        GestureDetector(
          onTap: widget.onDetailsTap,
          child: Text(
            'See Details',
            style: AppTextStyles.caption2.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(dynamic rating) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$rating',
                style: AppTextStyles.h2,
              ),
              TextSpan(
                text: ' /10',
                style: AppTextStyles.h3.copyWith(color: AppColors.grayLight),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(dynamic streak, dynamic tracked) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.local_fire_department,
              iconColor: AppColors.fireOrange,
              iconBgColor: AppColors.fireBackground,
              label: 'Streak',
              value: '$streak days',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 32,
            color: AppColors.grayLight.withValues(alpha: 0.2),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatItem(
              icon: Icons.fitness_center,
              iconColor: AppColors.waterBlue,
              iconBgColor: AppColors.waterBackground,
              label: 'Tracked',
              value: '$tracked',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.small.copyWith(color: AppColors.grayLight),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style:
                    AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

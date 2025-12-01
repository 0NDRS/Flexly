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
    _analysisData = fetchAnalysisData();
  }

  Future<Map<String, dynamic>> fetchAnalysisData() async {
    final String baseUrl =
        Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
    try {
      debugPrint('Fetching data from $baseUrl/api/analysis');
      final response = await http.get(Uri.parse('$baseUrl/api/analysis'));

      if (response.statusCode == 200) {
        debugPrint('Data fetched successfully: ${response.body}');
        return json.decode(response.body);
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
        throw Exception('Failed to load analysis data');
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      // Fallback data
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latest Stats',
                        style: AppTextStyles.caption2
                            .copyWith(color: AppColors.white),
                      ),
                      Text(
                        '30.10.2025',
                        style: AppTextStyles.small
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: widget.onDetailsTap,
                    child: Text(
                      'See Details',
                      style: AppTextStyles.caption2
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                      text: '${data['rating']}',
                      style: AppTextStyles.h2,
                    ),
                    TextSpan(
                      text: ' /10',
                      style:
                          AppTextStyles.h3.copyWith(color: AppColors.grayLight),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFF332B20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFFF9500),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Streak',
                                  style: AppTextStyles.small
                                      .copyWith(color: AppColors.grayLight),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${data['streak']} days',
                                  style: AppTextStyles.body2
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 28, 37, 46),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: Color.fromARGB(255, 48, 163, 209),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tracked',
                                  style: AppTextStyles.small
                                      .copyWith(color: AppColors.grayLight),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${data['analyticsTracked']}',
                                  style: AppTextStyles.body2
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
}

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_text_styles.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Statistics',
        style: AppTextStyles.h1,
      ),
    );
  }
}

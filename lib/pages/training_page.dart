import 'package:flutter/material.dart';
import 'package:flexly/theme/app_text_styles.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Training',
        style: AppTextStyles.h1,
      ),
    );
  }
}

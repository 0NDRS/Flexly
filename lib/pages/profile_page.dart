import 'package:flutter/material.dart';
import 'package:flexly/theme/app_text_styles.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Profile',
        style: AppTextStyles.h1,
      ),
    );
  }
}

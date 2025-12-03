import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/pages/login_page.dart';

// Test profile page for testing backend

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUser();
    setState(() {
      _userData = user;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 32),
              if (_userData != null) ...[
                _buildProfileItem('Name', _userData!['name']),
                const SizedBox(height: 16),
                _buildProfileItem('Email', _userData!['email']),
                const SizedBox(height: 16),
                _buildProfileItem('User ID', _userData!['_id']),
              ] else
                Text(
                  'No user data found',
                  style: AppTextStyles.body1,
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grayDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.gray),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Logout',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption1.copyWith(color: AppColors.grayLight),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body1,
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.gray),
      ],
    );
  }
}

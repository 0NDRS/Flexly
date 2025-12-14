import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/widgets/primary_button.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/pages/login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _themeEnabled = true;
  String _selectedUnits = 'Metric'; // 'Metric' or 'Imperial'

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
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header from profile page
                const HomeHeader(),
                const SizedBox(height: 32),

                // Account Section
                Text(
                  'Account',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildSettingItem(
                    icon: Icons.edit_outlined,
                    title: 'Edit profile',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.lock_outlined,
                    title: 'Change password',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 32),

                // App preferences Section
                Text(
                  'App preferences',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildSettingItemWithToggle(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItemWithUnits(
                    icon: Icons.straighten_outlined,
                    title: 'Units',
                    selectedUnits: _selectedUnits,
                    onUnitsChanged: (units) {
                      setState(() {
                        _selectedUnits = units;
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItemWithToggle(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    value: _themeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _themeEnabled = value;
                      });
                    },
                  ),
                ]),
                const SizedBox(height: 32),

                // Support Section
                Text(
                  'Support',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildSettingItem(
                    icon: Icons.help_outline,
                    title: 'Help centre',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.mail_outline,
                    title: 'Contact us',
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 32),

                // Logout Button
                PrimaryButton(
                  text: 'Log out',
                  onPressed: _handleLogout,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.grayDark,
          width: 1,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.grayLight,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItemWithToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.grayLight,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: value ? AppColors.primary : AppColors.gray,
                    ),
                  ),
                  AnimatedPositioned(
                    left: value ? 28 : 2,
                    top: 2,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value ? AppColors.white : AppColors.grayDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItemWithUnits({
    required IconData icon,
    required String title,
    required String selectedUnits,
    required ValueChanged<String> onUnitsChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.grayLight,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 16,
                color: AppColors.white,
              ),
            ),
          ),
          Row(
            children: [
              _buildUnitButton(
                label: 'Metric',
                isSelected: selectedUnits == 'Metric',
                onPressed: () => onUnitsChanged('Metric'),
              ),
              const SizedBox(width: 8),
              _buildUnitButton(
                label: 'Imperial',
                isSelected: selectedUnits == 'Imperial',
                onPressed: () => onUnitsChanged('Imperial'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.transparent,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.grayLight,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          fontSize: 13,
          color: isSelected ? AppColors.white : AppColors.grayLight,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.gray,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }
}

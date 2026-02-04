import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/widgets/primary_button.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/pages/login_page.dart';
import 'package:flexly/pages/edit_profile_page.dart';
import 'package:flexly/pages/change_password_page.dart';
import 'package:flexly/pages/privacy_security_page.dart';
import 'package:flexly/pages/terms_of_service_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/services/event_bus.dart';

import 'package:flexly/services/user_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _authService = AuthService();
  final _userService = UserService();
  bool _notificationsEnabled = true;
  String _selectedUnits = 'Metric';
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadUnitsPreference();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() {
        _userData = user;
      });
    }
  }

  Future<void> _loadUnitsPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUnits = prefs.getString('preferredUnits');
    if (savedUnits != null && mounted) {
      setState(() {
        _selectedUnits = savedUnits;
      });
    }
  }

  Future<void> _updateUnits(String units) async {
    if (_selectedUnits == units) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredUnits', units);
    if (mounted) {
      setState(() {
        _selectedUnits = units;
      });
    }
    EventBus().fire(UnitsPreferenceChangedEvent(units));
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

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grayDark,
        title:
            const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will delete all your data, including posts, follows, and comments.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;


      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await _userService.deleteAccount();
        if (!mounted) return;


        Navigator.pop(context);


        await _authService.logout();

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting account: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: AppTextStyles.h3,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),


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
                    onTap: () {
                      if (_userData == null) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(
                            userData: _userData!,
                          ),
                        ),
                      ).then((updated) {
                        if (updated == true) {
                          _loadUser();
                        }
                      });
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.lock_outlined,
                    title: 'Change password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  _buildDivider(),
                  _buildSettingItem(
                    icon: Icons.security_outlined,
                    title: 'Privacy & Security',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacySecurityPage(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),


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
                    onUnitsChanged: _updateUnits,
                  ),
                ]),
                const SizedBox(height: 32),


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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TermsOfServicePage(),
                        ),
                      );
                    },
                  ),
                ]),
                const SizedBox(height: 32),


                PrimaryButton(
                  text: 'Log out',
                  onPressed: _handleLogout,
                ),
                const SizedBox(height: 16),


                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _handleDeleteAccount,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(
                        color: AppColors.grayLight.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      'Delete Account',
                      style: AppTextStyles.button2.copyWith(
                        color: Colors.red.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
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

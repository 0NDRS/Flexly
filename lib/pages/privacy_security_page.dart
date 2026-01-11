import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  bool _biometricUnlock = false;
  bool _requirePasscode = true;
  bool _analytics = false;
  bool _crashReports = true;
  bool _marketingEmails = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricUnlock = prefs.getBool('privacy_biometric') ?? false;
      _requirePasscode = prefs.getBool('privacy_passcode') ?? true;
      _analytics = prefs.getBool('privacy_analytics') ?? false;
      _crashReports = prefs.getBool('privacy_crash_reports') ?? true;
      _marketingEmails = prefs.getBool('privacy_marketing_emails') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
        title: Text('Privacy & Security', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionHeader('Security'),
              const SizedBox(height: 12),
              _card([
                _toggleRow(
                  icon: Icons.fingerprint,
                  title: 'Biometric unlock',
                  value: _biometricUnlock,
                  onChanged: (v) {
                    setState(() => _biometricUnlock = v);
                    _save('privacy_biometric', v);
                    _showSnack(v ? 'Biometric unlock enabled' : 'Biometric unlock disabled');
                  },
                ),
                _divider(),
                _toggleRow(
                  icon: Icons.shield_outlined,
                  title: 'Require passcode on launch',
                  value: _requirePasscode,
                  onChanged: (v) {
                    setState(() => _requirePasscode = v);
                    _save('privacy_passcode', v);
                    _showSnack(v ? 'Passcode requirement on' : 'Passcode requirement off');
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _sectionHeader('Data & Analytics'),
              const SizedBox(height: 12),
              _card([
                _toggleRow(
                  icon: Icons.insights_outlined,
                  title: 'Anonymized analytics',
                  value: _analytics,
                  onChanged: (v) {
                    setState(() => _analytics = v);
                    _save('privacy_analytics', v);
                    _showSnack(v ? 'Analytics sharing enabled' : 'Analytics sharing disabled');
                  },
                ),
                _divider(),
                _toggleRow(
                  icon: Icons.bug_report_outlined,
                  title: 'Crash reports',
                  value: _crashReports,
                  onChanged: (v) {
                    setState(() => _crashReports = v);
                    _save('privacy_crash_reports', v);
                    _showSnack(v ? 'Crash reports enabled' : 'Crash reports disabled');
                  },
                ),
                _divider(),
                _toggleRow(
                  icon: Icons.mail_outline,
                  title: 'Product updates & tips',
                  value: _marketingEmails,
                  onChanged: (v) {
                    setState(() => _marketingEmails = v);
                    _save('privacy_marketing_emails', v);
                    _showSnack(v ? 'Product emails enabled' : 'Product emails disabled');
                  },
                ),
              ]),
              const SizedBox(height: 24),
              _sectionHeader('Your data'),
              const SizedBox(height: 12),
              _card([
                _actionRow(
                  icon: Icons.file_download_outlined,
                  title: 'Download my data (zip)',
                  onTap: () => _showSnack('Data export requested'),
                ),
                _divider(),
                _actionRow(
                  icon: Icons.delete_outline,
                  title: 'Request account deletion',
                  onTap: () => _showSnack('Deletion request submitted'),
                  destructive: true,
                ),
              ]),
              const SizedBox(height: 24),
              _sectionHeader('Legal'),
              const SizedBox(height: 12),
              _card([
                _actionRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _showSnack('Opening privacy policy'),
                ),
                _divider(),
                _actionRow(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  onTap: () => _showSnack('Opening terms of service'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Text(
      text,
      style: AppTextStyles.h2.copyWith(fontSize: 20, color: AppColors.white),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grayDark, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: AppColors.gray,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.grayLight, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.h3.copyWith(fontSize: 16, color: AppColors.white),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 56,
              height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
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

  Widget _actionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Icon(icon, color: destructive ? Colors.redAccent : AppColors.grayLight, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: destructive ? Colors.redAccent : AppColors.white,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.grayLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

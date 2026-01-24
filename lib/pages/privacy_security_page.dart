import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flexly/services/lock_service.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/pages/privacy_policy_page.dart';
import 'package:flexly/pages/terms_of_service_page.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  final _lockService = LockService();
  final _localAuth = LocalAuthentication();
  bool _biometricUnlock = false;
  bool _requirePasscode = false;
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
      _requirePasscode = prefs.getBool('privacy_passcode') ?? false;
      _analytics = prefs.getBool('privacy_analytics') ?? false;
      _crashReports = prefs.getBool('privacy_crash_reports') ?? true;
      _marketingEmails = prefs.getBool('privacy_marketing_emails') ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> _ensurePasscodeSet() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString('privacy_passcode_code');
    if (existing != null && existing.isNotEmpty) return true;

    if (!mounted) return false;

    final controller1 = TextEditingController();
    final controller2 = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.grayDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set passcode', style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Text(
                  'Use 4-8 digits. You\'ll need this if biometrics are unavailable.',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 16),
                _styledField(
                  controller: controller1,
                  label: 'Passcode',
                  hint: 'Enter 4-8 digits',
                ),
                const SizedBox(height: 12),
                _styledField(
                  controller: controller2,
                  label: 'Confirm passcode',
                  hint: 'Re-enter passcode',
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      onPressed: () {
                        final p1 = controller1.text.trim();
                        final p2 = controller2.text.trim();
                        if (p1.length < 4 || p1.length > 8) {
                          _showSnack('Passcode must be 4-8 digits');
                          return;
                        }
                        if (p1 != p2) {
                          _showSnack('Passcodes do not match');
                          return;
                        }
                        prefs.setString('privacy_passcode_code', p1);
                        Navigator.pop(context, true);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return result ?? false;
  }

  Widget _styledField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.body2.copyWith(color: AppColors.grayLight)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.gray,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
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
                  onChanged: (v) async {
                    if (v) {
                      final supported = await _lockService.canUseBiometrics();
                      if (!supported) {
                        _showSnack('Biometrics not available or not enrolled');
                        return;
                      }
                      final biometrics =
                          await _localAuth.getAvailableBiometrics();
                      if (biometrics.isEmpty) {
                        _showSnack(
                            'Enroll fingerprint/face to enable biometrics');
                        return;
                      }
                      final ok = await _localAuth.authenticate(
                        localizedReason: 'Enable biometric unlock',
                        options: const AuthenticationOptions(
                          biometricOnly: true,
                          stickyAuth: true,
                        ),
                      );
                      if (!ok) {
                        _showSnack('Biometric check failed');
                        return;
                      }
                    }
                    setState(() => _biometricUnlock = v);
                    _save('privacy_biometric', v);
                    _showSnack(v
                        ? 'Biometric unlock enabled'
                        : 'Biometric unlock disabled');
                  },
                ),
                _divider(),
                _toggleRow(
                  icon: Icons.shield_outlined,
                  title: 'Require passcode on launch',
                  value: _requirePasscode,
                  onChanged: (v) async {
                    if (v) {
                      final created = await _ensurePasscodeSet();
                      if (!created) return;
                    }
                    setState(() => _requirePasscode = v);
                    _save('privacy_passcode', v);
                    _showSnack(v
                        ? 'Passcode requirement on'
                        : 'Passcode requirement off');
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
                  onChanged: (v) async {
                    setState(() => _analytics = v);
                    _save('privacy_analytics', v);
                    // When anonymized analytics is ON, hide from social feed (socialHidden = true)
                    final auth = AuthService();
                    final resp = await auth.updateProfile({
                      'socialHidden': v ? 'true' : 'false',
                    });
                    if (!(resp['success'] == true)) {
                      // revert locally on failure
                      setState(() => _analytics = !v);
                      _save('privacy_analytics', !v);
                      _showSnack('Could not update privacy setting');
                      return;
                    }
                    _showSnack(v
                        ? 'Anonymized mode on – hidden from feed/social'
                        : 'Anonymized mode off – visible in social');
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
                    _showSnack(
                        v ? 'Crash reports enabled' : 'Crash reports disabled');
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
                    _showSnack(v
                        ? 'Product emails enabled'
                        : 'Product emails disabled');
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                _divider(),
                _actionRow(
                  icon: Icons.article_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TermsOfServicePage()),
                    );
                  },
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
              style: AppTextStyles.h3
                  .copyWith(fontSize: 16, color: AppColors.white),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 56,
              height: 32,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
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
              Icon(icon,
                  color: destructive ? Colors.redAccent : AppColors.grayLight,
                  size: 24),
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

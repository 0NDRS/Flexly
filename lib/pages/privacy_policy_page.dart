import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        title: Text('Privacy Policy', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Header(text: 'Last updated: Jan 19, 2026'),
              _Section(
                title: 'Overview',
                body:
                    'Flexly helps you track your wellness and performance. This policy explains what data we collect, why we collect it, and how you can control it.',
              ),
              _Section(
                title: 'What we collect',
                bullets: [
                  'Account info you provide (name, email, password hash).',
                  'Session data to keep you signed in securely.',
                  'Optional analytics about app usage (toggleable in Settings > Privacy & Security).',
                  'Crash reports to improve stability (toggleable).',
                  'Activity data you enter or sync within the app.',
                ],
              ),
              _Section(
                title: 'How we use data',
                bullets: [
                  'Operate the app and personalize your experience.',
                  'Provide support and troubleshoot issues.',
                  'Improve features through aggregated analytics.',
                  'Detect, prevent, and address security or abuse.',
                ],
              ),
              _Section(
                title: 'Your choices',
                bullets: [
                  'Manage analytics and crash reporting from Settings > Privacy & Security.',
                  'Download your data or request account deletion from Settings > Privacy & Security.',
                  'Update your account info in Settings > Account.',
                ],
              ),
              _Section(
                title: 'Data sharing',
                bullets: [
                  'We do not sell your personal data.',
                  'Trusted service providers (e.g., hosting, analytics) only process data on our behalf under confidentiality terms.',
                  'We may share data if required by law or to protect the safety and security of users.',
                ],
              ),
              _Section(
                title: 'Data retention',
                body:
                    'We keep your data while your account is active. If you delete your account, we remove or anonymize personal data unless we need to retain it for legal obligations or dispute resolution.',
              ),
              _Section(
                title: 'Security',
                body:
                    'We use encryption in transit, access controls, and monitoring to protect your data. No method is 100% secure, so we encourage using a strong password and enabling biometric/passcode lock.',
              ),
              _Section(
                title: 'Children',
                body:
                    'Flexly is not directed to children under 13, and we do not knowingly collect data from them.',
              ),
              _Section(
                title: 'Contact',
                body:
                    'Questions or requests? Email us at privacy@flexly.app. We aim to respond promptly.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String text;

  const _Header({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? body;
  final List<String>? bullets;

  const _Section({required this.title, this.body, this.bullets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h2.copyWith(fontSize: 20, color: AppColors.white),
          ),
          const SizedBox(height: 8),
          if (body != null)
            Text(
              body!,
              style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
            ),
          if (bullets != null) ...bullets!.map(
            (b) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: AppTextStyles.body2.copyWith(color: AppColors.grayLight)),
                  Expanded(
                    child: Text(
                      b,
                      style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
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
}

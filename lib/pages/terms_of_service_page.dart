import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
        title: Text('Terms of Service', style: AppTextStyles.h3),
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
                title: 'Agreement',
                body:
                    'By using Flexly you agree to these Terms of Service. If you do not agree, do not use the app.',
              ),
              _Section(
                title: 'Eligibility & account',
                bullets: [
                  'You must be at least 13 years old and legally able to agree to these terms.',
                  'Keep your account credentials secure and let us know if you suspect unauthorized access.',
                  'You are responsible for all activity under your account.',
                ],
              ),
              _Section(
                title: 'Use of Flexly',
                bullets: [
                  'Use the app only for lawful purposes and in accordance with our policies.',
                  'Do not misuse, disrupt, or attempt to reverse engineer the service.',
                  'We may update, limit, or discontinue features to improve reliability and security.',
                ],
              ),
              _Section(
                title: 'Content & data',
                bullets: [
                  'You retain rights to the content you upload. You grant us a limited license to store and process it to provide the service.',
                  'Do not upload content that is unlawful, abusive, or infringes others’ rights.',
                  'Aggregated or de-identified data may be used to improve Flexly and analytics.',
                ],
              ),
              _Section(
                title: 'Health disclaimer',
                body:
                    'Flexly does not provide medical advice. Consult a healthcare professional before making training or health decisions. Use the app at your own risk.',
              ),
              _Section(
                title: 'Subscriptions & payments',
                body:
                    'If paid features are offered, billing is handled by the app store. Applicable taxes and store terms apply. We do not handle card data directly.',
              ),
              _Section(
                title: 'Termination',
                bullets: [
                  'You may stop using Flexly at any time. You can request account deletion in Settings > Privacy & Security.',
                  'We may suspend or terminate access for violations of these terms or to protect the service or other users.',
                ],
              ),
              _Section(
                title: 'Liability',
                body:
                    'Flexly is provided “as is” without warranties. To the maximum extent permitted by law, our liability is limited to the amount you paid (if any) for the service in the last 12 months.',
              ),
              _Section(
                title: 'Changes to these terms',
                body:
                    'We may update these terms. We will notify you of material changes. Continued use after changes means you accept the updated terms.',
              ),
              _Section(
                title: 'Contact',
                body:
                    'Questions about these terms? Email us at legal@flexly.app.',
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

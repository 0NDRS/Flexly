import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/pages/select_plan_page.dart';
import 'package:flexly/widgets/primary_button.dart';

class BodyInfoPage extends StatefulWidget {
  const BodyInfoPage({super.key});

  @override
  State<BodyInfoPage> createState() => _BodyInfoPageState();
}

class _BodyInfoPageState extends State<BodyInfoPage> {
  String? selectedGender;
  final TextEditingController _ageController = TextEditingController(text: '18');
  final TextEditingController _heightController = TextEditingController(text: '180');
  final TextEditingController _weightController = TextEditingController(text: '70');
  
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with logo and text
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(34),
                                  child: Image.asset(
                                    'assets/icon/app_icon.png',
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Tell us about\nyourself',
                                      style: AppTextStyles.h1.copyWith(
                                        fontSize: 28,
                                        color: AppColors.white,
                                        height: 1.2,
                                      ),
                                      maxLines: 3,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Powered by Flex Intelligence™',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.grayLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Gender Input
                      _buildInputField(
                        label: 'Gender',
                        value: selectedGender ?? 'Male',
                        onTap: () => _showGenderPicker(),
                      ),
                      const SizedBox(height: 16),
                      // Age Input
                      _buildTextInputField(
                        label: 'Age',
                        controller: _ageController,
                        unit: 'years',
                        focusNode: _ageFocusNode,
                      ),
                      const SizedBox(height: 16),
                      // Height Input
                      _buildTextInputField(
                        label: 'Height',
                        controller: _heightController,
                        unit: 'cm',
                        focusNode: _heightFocusNode,
                      ),
                      const SizedBox(height: 16),
                      // Weight Input
                      _buildTextInputField(
                        label: 'Weight',
                        controller: _weightController,
                        unit: 'kg',
                        focusNode: _weightFocusNode,
                      ),
                      const SizedBox(height: 32),
                      // Continue Button
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'Continue',
                          onPressed: _handleContinue,
                          size: ButtonSize.large,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // Skip Option at Bottom
                  Column(
                    children: [
                      Text(
                        'Prefer to do this later?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.grayLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _handleSkip,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Skip',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '>',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.grayLight,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.white,
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputField({
    required String label,
    required TextEditingController controller,
    required String unit,
    required FocusNode focusNode,
  }) {
    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.gray,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.grayLight,
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: AppTextStyles.body1.copyWith(
                    color: AppColors.grayLight,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                ),
              ),
            ),
            Text(
              unit,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.grayDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select Gender',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: genderOptions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      genderOptions[index],
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedGender = genderOptions[index];
                      });
                      Navigator.pop(context);
                    },
                    trailing: selectedGender == genderOptions[index]
                        ? const Icon(
                            Icons.check,
                            color: AppColors.primary,
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    // TODO: Save body info to backend
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SelectPlanPage()),
    );
  }

  void _handleSkip() {
    // Navigate to home without saving body info
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}

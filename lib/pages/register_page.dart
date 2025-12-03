import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/services/auth_service.dart';

// Test register page for testing backend authentication

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'Create Account',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 32,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Join Flexly today',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.grayLight,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                Text(
                  'Full Name',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle:
                        AppTextStyles.body1.copyWith(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.grayDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Email',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle:
                        AppTextStyles.body1.copyWith(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.grayDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Password',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    hintStyle:
                        AppTextStyles.body1.copyWith(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.grayDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Confirm Password',
                  style:
                      AppTextStyles.body2.copyWith(color: AppColors.grayLight),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle:
                        AppTextStyles.body1.copyWith(color: AppColors.gray),
                    filled: true,
                    fillColor: AppColors.grayDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white)
                        : Text(
                            'Register',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.grayLight),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

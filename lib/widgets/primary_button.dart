import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

enum ButtonSize { small, large }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.large,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final double height = size == ButtonSize.large ? 56.0 : 40.0;
    final double padding = size == ButtonSize.large ? 24.0 : 16.0;
    final TextStyle textStyle = size == ButtonSize.large
        ? AppTextStyles.button2
        : AppTextStyles.caption1.copyWith(fontWeight: FontWeight.w600);

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: padding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: textStyle,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text),
          ],
        ),
      ),
    );
  }
}

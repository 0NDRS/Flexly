import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';

class StatisticsGraph extends StatelessWidget {
  const StatisticsGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Grid Lines
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGridLine('10'),
                    _buildGridLine('6'),
                    _buildGridLine('3'),
                    _buildGridLine('0'),
                  ],
                ),
                // Bars
                Positioned(
                  left: 16,
                  top: 8,
                  bottom: 8,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar('Mon', 5, false),
                      _buildBar('Tue', 6.7, true),
                      _buildBar('Wed', 0, false),
                      _buildBar('Thu', 0, false),
                      _buildBar('Fri', 0, false),
                      _buildBar('Sat', 0, false),
                      _buildBar('Sun', 0, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // X-Axis Labels
          Padding(
            padding: const EdgeInsets.only(left: 16), // Reduced from 24
            child: Row(
              children: [
                _buildXLabel('Mon'),
                _buildXLabel('Tue'),
                _buildXLabel('Wed'),
                _buildXLabel('Thu'),
                _buildXLabel('Fri'),
                _buildXLabel('Sat'),
                _buildXLabel('Sun'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLine(String label) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.grayLight),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: CustomPaint(
            painter: DashedLinePainter(),
          ),
        ),
      ],
    );
  }

  Widget _buildXLabel(String label) {
    return Expanded(
      child: Text(
        label,
        style: AppTextStyles.small.copyWith(color: AppColors.grayLight),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBar(String day, double value, bool isSelected) {
    const double totalHeight = 184;
    final double barHeight = (value / 10) * totalHeight;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isSelected) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000), // Darker red for tooltip bg
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style:
                    AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            CustomPaint(
              size: const Size(10, 6),
              painter: TrianglePainter(),
            ),
            const SizedBox(height: 4),
          ],
          Container(
            width: 24,
            height: barHeight,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFF7A3E3E), // Less vibrant, darker red
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grayLight.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF8B0000);
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

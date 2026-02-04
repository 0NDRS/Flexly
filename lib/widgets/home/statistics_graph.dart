import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class StatisticsGraph extends StatelessWidget {
  final List<dynamic> analyses;

  const StatisticsGraph({
    super.key,
    this.analyses = const [],
  });

  List<Map<String, dynamic>> get _chartData {
    final now = DateTime.now();
    final List<Map<String, dynamic>> data = [];


    final Map<String, double> analysisMap = {};
    for (var analysis in analyses) {
      if (analysis['createdAt'] != null && analysis['ratings'] != null) {
        final date = DateTime.parse(analysis['createdAt']).toLocal();
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        final score =
            (analysis['ratings']['overall'] as num?)?.toDouble() ?? 0.0;

        if (!analysisMap.containsKey(dateKey)) {
          analysisMap[dateKey] = score;
        }
      }
    }


    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(day);
      final dayLabel = DateFormat('E').format(day);

      data.add({
        'day': dayLabel,
        'value': analysisMap[dateKey] ?? 0.0,
        'selected': i == 0,
      });
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _chartData;

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
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildGridLine('10.0'),
                    _buildGridLine('7.5'),
                    _buildGridLine('5.0'),
                    _buildGridLine('2.5'),
                    _buildGridLine('0.0'),
                  ],
                ),
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data
                        .map((item) => _buildBar(
                              item['day'] as String,
                              item['value'] as double,
                              item['selected'] as bool,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Row(
              children: data
                  .map((item) => _buildXLabel(item['day'] as String))
                  .toList(),
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
          width: 24,
          child: Text(
            label,
            style: AppTextStyles.small
                .copyWith(color: AppColors.grayLight, fontSize: 10),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
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



    return Expanded(
      child: LayoutBuilder(builder: (context, constraints) {
        final height = constraints.maxHeight;
        final barHeight = (value / 10.0) * height;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isSelected && value > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.tooltipBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  value.toStringAsFixed(1),
                  style: AppTextStyles.caption1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Colors.white),
                ),
              ),
              CustomPaint(
                size: const Size(6, 4),
                painter: TrianglePainter(),
              ),
              const SizedBox(height: 2),
            ],
            Container(
              width: 12,
              height: barHeight > 0 ? barHeight : 2,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.barInactive,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
          ],
        );
      }),
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
    final paint = Paint()..color = AppColors.tooltipBackground;
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

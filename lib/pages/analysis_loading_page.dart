import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/services/event_bus.dart';

class AnalysisLoadingPage extends StatefulWidget {
  const AnalysisLoadingPage({super.key});

  @override
  State<AnalysisLoadingPage> createState() => _AnalysisLoadingPageState();
}

class _AnalysisLoadingPageState extends State<AnalysisLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<File> _selectedImages = [];
  bool _isScanning = false;
  bool _isCompleted = false;
  String? _error;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _handleAddPhotos() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 images allowed')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (!mounted) return;

      if (images.isNotEmpty) {
        final int remainingSlots = 3 - _selectedImages.length;

        setState(() {
          final imagesToAdd =
              images.take(remainingSlots).map((image) => File(image.path));
          _selectedImages.addAll(imagesToAdd);
          _error = null;
        });

        if (images.length > remainingSlots) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only the first 3 images were added')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error picking images: $e';
      });
    }
  }

  Future<void> _startAnalysis() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isScanning = true;
      _error = null;
    });

    try {
      final analysisService = AnalysisService();
      final result = await analysisService.uploadAndAnalyze(_selectedImages);

      // Fire event to update other pages (like Profile)
      EventBus().fire(AnalysisCreatedEvent(result));

      if (mounted) {
        setState(() {
          _isCompleted = true;
          _isScanning = false;
          _result = result;
          _controller.stop();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _error = e.toString();
        });
      }
    }
  }

  void _navigateToResults() {
    if (_result == null) return;

    final ratings = _result!['ratings'];
    final advice = _result!['advice'];
    final adviceTitle = _result!['adviceTitle'] ?? 'AI Analysis Advice';
    final dateStr = _result!['createdAt'];
    final date = DateTime.parse(dateStr);
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    final Map<String, double> bodyPartRatings = {
      'Arms': (ratings['arms'] as num).toDouble(),
      'Chest': (ratings['chest'] as num).toDouble(),
      'Abs': (ratings['abs'] as num).toDouble(),
      'Shoulders': (ratings['shoulders'] as num).toDouble(),
      'Legs': (ratings['legs'] as num).toDouble(),
      'Back': (ratings['back'] as num).toDouble(),
    };

    List<String> imageUrls = [];
    if (_result!['imageUrls'] != null) {
      imageUrls = (_result!['imageUrls'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailPage(
          date: formattedDate,
          overallRating: (ratings['overall'] as num).toDouble(),
          bodyPartRatings: bodyPartRatings,
          adviceTitle: adviceTitle,
          adviceDescription: advice,
          imageUrls: imageUrls,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('AI Analysis', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error != null) ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Analysis Failed',
                  style: AppTextStyles.h2.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body1
                        .copyWith(color: AppColors.grayLight),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.grayDark,
                  ),
                  child: Text('Try Again', style: AppTextStyles.button2),
                ),
              ] else if (_isCompleted) ...[
                Icon(Icons.check_circle_outline,
                    color: AppColors.primary, size: 64),
                const SizedBox(height: 24),
                Text(
                  'Analysis Complete!',
                  style: AppTextStyles.h2.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _navigateToResults,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Show Results',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ] else ...[
                // Scanner UI
                if (_isScanning)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Scanning...',
                      style: AppTextStyles.h3.copyWith(color: AppColors.white),
                    ),
                  )
                else
                  Text(
                    '${_selectedImages.length}/3 Photos Selected',
                    style: AppTextStyles.h3.copyWith(color: AppColors.white),
                  ),

                const SizedBox(height: 40),

                // Scanner Frame
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gray, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Show selected images preview if any
                      if (_selectedImages.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _selectedImages.length == 1
                              ? Image.file(
                                  _selectedImages.first,
                                  width: 296,
                                  height: 296,
                                  fit: BoxFit.cover,
                                  opacity: const AlwaysStoppedAnimation(0.5),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemCount: _selectedImages.length,
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        _selectedImages[index],
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  },
                                ),
                        ),

                      // Scanning line animation (only when scanning)
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Positioned(
                              top: _controller.value * 280,
                              child: Container(
                                width: 280,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                if (_isScanning)
                  Text(
                    'Analyzing your physique...',
                    style: AppTextStyles.body1
                        .copyWith(color: AppColors.grayLight),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: 200,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleAddPhotos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Add Images',
                            style: AppTextStyles.h3
                                .copyWith(color: AppColors.white),
                          ),
                        ),
                      ),
                      if (_selectedImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 200,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _startAnalysis,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'Start Analysis',
                              style: AppTextStyles.h3
                                  .copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/training_service.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:intl/intl.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final _trainingService = TrainingService();
  final _authService = AuthService();

  List<dynamic> _plans = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.getUser();
      final result = await _trainingService.getTrainingPlans();

      if (mounted) {
        setState(() {
          _userData = user;
          _plans = result['plans'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading plans: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _generatePlan() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final newPlan = await _trainingService.generateTrainingPlan();
      await _loadData();

      // Fire event to notify other pages
      EventBus().fire(TrainingPlanCreatedEvent(newPlan));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Training plan generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        HomeHeader(userData: _userData),
                        const SizedBox(height: 24),

                        // Generate Button Card
                        _buildGenerateCard(),
                        const SizedBox(height: 24),

                        // History Section
                        Text(
                          'Training History',
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_plans.isEmpty)
                          _buildEmptyState()
                        else
                          ..._plans.map((plan) => _buildPlanCard(plan)),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildGenerateCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.grayDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Get Your Personalized Plan',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'AI-powered training plan based on your physique analysis and goals',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.grayLight,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isGenerating ? null : _generatePlan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isGenerating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Generate Training Plan',
                          style: AppTextStyles.button2,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.grayLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No training plans yet',
            style: AppTextStyles.h3.copyWith(
              color: AppColors.grayLight,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first personalized training plan above!',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.grayLight.withValues(alpha: 0.7),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final createdAt = DateTime.parse(plan['createdAt']);
    final formattedDate = DateFormat('MMM d, yyyy').format(createdAt);

    return GestureDetector(
      onTap: () => _showPlanDetails(plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              plan['title'] ?? 'Training Plan',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.white,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => _showPlanDetails(plan),
                            child: Text(
                              'See Details',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.grayLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              plan['description'] ?? '',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.grayLight,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPlanStat(
                  Icons.fitness_center,
                  '${_countWorkoutDays(plan)} days',
                ),
                const SizedBox(width: 16),
                _buildPlanStat(
                  Icons.lightbulb_outline,
                  '${(plan['tips'] as List?)?.length ?? 0} tips',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grayLight),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.grayLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  int _countWorkoutDays(Map<String, dynamic> plan) {
    final weekPlan = plan['weekPlan'] as List?;
    if (weekPlan == null) return 0;
    return weekPlan.where((day) => day['isRestDay'] != true).length;
  }

  void _showPlanDetails(Map<String, dynamic> plan) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingPlanDetailPage(plan: plan),
      ),
    );
    if (deleted == true) {
      _loadData();
    }
  }
}

class TrainingPlanDetailPage extends StatefulWidget {
  final Map<String, dynamic> plan;

  const TrainingPlanDetailPage({super.key, required this.plan});

  @override
  State<TrainingPlanDetailPage> createState() => _TrainingPlanDetailPageState();
}

class _TrainingPlanDetailPageState extends State<TrainingPlanDetailPage>
    with SingleTickerProviderStateMixin {
  final _trainingService = TrainingService();
  late TabController _tabController;
  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _deletePlan() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grayDark,
        title: const Text('Delete Plan', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this training plan?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _trainingService.deleteTrainingPlan(widget.plan['_id']);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Map<String, dynamic>? _getDayPlan(String day) {
    final weekPlan = widget.plan['weekPlan'] as List?;
    if (weekPlan == null) return null;

    try {
      return weekPlan.firstWhere(
        (d) => d['day'].toString().toLowerCase() == day.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(widget.plan['createdAt']);
    final formattedDate = DateFormat('MMMM d, yyyy').format(createdAt);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Training Plan', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _deletePlan,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.plan['title'] ?? 'Training Plan',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.grayLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.plan['description'] ?? '',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.grayLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Day Tabs
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.grayDark,
              borderRadius: BorderRadius.circular(22),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(22),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.grayLight,
              labelStyle: AppTextStyles.body2.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTextStyles.body2.copyWith(fontSize: 12),
              dividerColor: Colors.transparent,
              tabs: _days.map((day) => Tab(text: day.substring(0, 3))).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Day Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _days.map((day) {
                final dayPlan = _getDayPlan(day);
                return _buildDayContent(dayPlan);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayContent(Map<String, dynamic>? dayPlan) {
    if (dayPlan == null) {
      return Center(
        child: Text(
          'No plan for this day',
          style: AppTextStyles.body1.copyWith(color: AppColors.grayLight),
        ),
      );
    }

    final isRestDay = dayPlan['isRestDay'] == true;
    final exercises = dayPlan['exercises'] as List? ?? [];

    if (isRestDay) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.waterBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement,
                size: 48,
                color: AppColors.waterBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rest Day',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Take time to recover and grow stronger',
              style: AppTextStyles.body2.copyWith(color: AppColors.grayLight),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Focus Area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.track_changes, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.grayLight,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    dayPlan['focus'] ?? 'Workout',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Exercises
        ...exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _buildExerciseCard(exercise, index + 1);
        }),

        // Tips Section (scrollable)
        if ((widget.plan['tips'] as List?)?.isNotEmpty == true)
          _buildTipsSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$number',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'] ?? '',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.white,
                    fontSize: 15,
                  ),
                ),
                if (exercise['notes'] != null &&
                    exercise['notes'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      exercise['notes'],
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.grayLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${exercise['sets']} × ${exercise['reps']}',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    final tips = widget.plan['tips'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fireBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.fireOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: AppColors.fireOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pro Tips',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.fireOrange,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '•  ',
                      style: TextStyle(
                        color: AppColors.fireOrange,
                        fontSize: 14,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

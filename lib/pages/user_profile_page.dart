import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/user_service.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:flexly/utils/unit_utils.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _userService = UserService();
  final _analysisService = AnalysisService();
  Map<String, dynamic>? _userData;
  List<dynamic> _analyses = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  String _unitSystem = UnitUtils.metric;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUnitPreference();
  }

  Future<void> _loadData() async {
    try {
      // Fetch User Profile
      final user = await _userService.getUserProfile(widget.userId);
      // Fetch User Analyses
      final analyses =
          await _analysisService.getAnalysesByUserId(widget.userId);

      if (mounted) {
        setState(() {
          _userData = user;
          _analyses = analyses;
          _isFollowing = user['isFollowing'] ?? false;
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
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUnitPreference() async {
    final preference = await UnitUtils.getPreferredUnits();
    if (mounted) {
      setState(() {
        _unitSystem = preference;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isFollowLoading) return;
    setState(() => _isFollowLoading = true);
    try {
      final newStatus = await _userService.followUser(widget.userId);
      if (mounted) {
        setState(() {
          _isFollowing = newStatus;
          _isFollowLoading = false;
          // Update followers count locally for immediate feedback
          if (_userData != null) {
            int currentFollowers = _userData!['followers'] ?? 0;
            _userData!['followers'] =
                newStatus ? currentFollowers + 1 : currentFollowers - 1;
          }
        });
        EventBus().fire(UserFollowEvent());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFollowLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Action failed: $e')),
        );
      }
    }
  }

  double _calculateAverageScore() {
    if (_analyses.isEmpty) return 0.0;
    double total = 0;
    int count = 0;
    for (var analysis in _analyses) {
      final ratings = analysis['ratings'] as Map<String, dynamic>?;
      if (ratings != null && ratings.containsKey('overall')) {
        final double val = (ratings['overall'] as num).toDouble();
        if (val > 0) {
          total += val;
          count++;
        }
      }
    }
    return count > 0 ? double.parse((total / count).toStringAsFixed(1)) : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: AppColors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.white),
        title:
            Text(_userData?['username'] ?? 'Profile', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),

                // Profile Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Profile Image
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          color: AppColors.grayLight,
                          image: _userData?['profilePicture'] != null &&
                                  _userData!['profilePicture'] != ''
                              ? DecorationImage(
                                  image: NetworkImage(
                                      _userData!['profilePicture']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _userData?['profilePicture'] == null ||
                                _userData!['profilePicture'] == ''
                            ? const Icon(Icons.person,
                                size: 60, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        _userData?['name'] ?? 'User',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userData?['username'] != null
                            ? '@${_userData!['username']}'
                            : '@username',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.grayLight,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Follow Button
                      SizedBox(
                        width: 140,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing
                                ? AppColors.gray
                                : AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: _isFollowLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: AppTextStyles.button2
                                      .copyWith(color: Colors.white),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Stats row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                              'Followers', '${_userData?['followers'] ?? 0}'),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.grayLight.withValues(alpha: 0.2),
                          ),
                          _buildStatColumn(
                              'Following', '${_userData?['following'] ?? 0}'),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.grayLight.withValues(alpha: 0.2),
                          ),
                          _buildStatColumn(
                              'Avg. Rating', '${_calculateAverageScore()}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Divider(
                          color: AppColors.grayLight.withValues(alpha: 0.2)),
                      const SizedBox(height: 16),
                      // Body Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn(
                              'Gender', '${_userData?['gender'] ?? '-'}'),
                          _buildStatColumn(
                              'Age', '${_userData?['age'] ?? '-'}'),
                          _buildStatColumn(
                              'Height',
                              UnitUtils.formatHeight(
                                _userData?['height'], _unitSystem)),
                            _buildStatColumn(
                              'Weight',
                              UnitUtils.formatWeight(
                                _userData?['weight'], _unitSystem)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Streak and Analytics row
                Row(
                  children: [
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.local_fire_department,
                        label: 'Streak',
                        value:
                            '${AnalysisService.calculateStreak(_analyses)} days',
                        iconColor: AppColors.fireOrange,
                        iconBgColor: AppColors.fireBackground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.analytics_outlined,
                        label: 'Analyses',
                        value: '${_analyses.length}',
                        iconColor: AppColors.waterBlue,
                        iconBgColor: AppColors.waterBackground,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Posts Section
                Text(
                  'Posts',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Posts Grid
                _analyses.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text('No posts yet',
                              style: AppTextStyles.body2
                                  .copyWith(color: AppColors.grayLight)),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.grayDark,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.grayDark,
                            width: 1,
                          ),
                        ),
                        child: GridView.builder(
                          itemCount: _analyses.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final analysis = _analyses[index];
                            final imageUrls = (analysis['imageUrls'] as List)
                                .map((e) => e.toString())
                                .toList();
                            final firstImageUrl =
                                imageUrls.isNotEmpty ? imageUrls[0] : null;

                            final ratingsMap =
                                analysis['ratings'] as Map<String, dynamic>;
                            final double overall =
                                (ratingsMap['overall'] as num).toDouble();

                            return GestureDetector(
                              onTap: () {
                                final bodyParts =
                                    Map<String, double>.fromEntries(
                                  ratingsMap.entries
                                      .where((e) => e.key != 'overall')
                                      .map((e) => MapEntry(
                                          e.key, (e.value as num).toDouble())),
                                );

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnalysisDetailPage(
                                      date: DateFormat('dd.MM.yyyy').format(
                                          DateTime.parse(
                                              analysis['createdAt'])),
                                      overallRating: overall,
                                      bodyPartRatings: bodyParts,
                                      adviceTitle:
                                          analysis['adviceTitle'] ?? 'Analysis',
                                      adviceDescription:
                                          analysis['advice'] ?? '',
                                      imageUrls: imageUrls,
                                      isMe: false,
                                      analysisId: analysis['_id'],
                                    ),
                                  ),
                                );
                              },
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.grayLight,
                                      borderRadius: BorderRadius.circular(12),
                                      image: firstImageUrl != null
                                          ? DecorationImage(
                                              image:
                                                  NetworkImage(firstImageUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                            Icon(Icons.star,
                                              size: 10,
                                              color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            overall.toStringAsFixed(1),
                                            style: AppTextStyles.small.copyWith(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.h3
                .copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: AppTextStyles.small.copyWith(color: AppColors.grayLight)),
      ],
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grayDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: AppTextStyles.h3.copyWith(
                  color: AppColors.white, fontWeight: FontWeight.bold)),
          Text(label,
              style: AppTextStyles.small.copyWith(color: AppColors.grayLight)),
        ],
      ),
    );
  }
}

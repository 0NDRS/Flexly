import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:flexly/pages/edit_profile_page.dart';
import 'package:flexly/pages/login_page.dart';
import 'package:flexly/pages/settings_page.dart';
import 'package:flexly/pages/streak_page.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/utils/unit_utils.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback? onNavigateToAnalysis;

  const ProfilePage({super.key, this.onNavigateToAnalysis});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _analysisService = AnalysisService();
  Map<String, dynamic>? _userData;
  List<dynamic> _analyses = [];
  bool _isLoading = true;
  StreamSubscription? _eventSubscription;
  String _unitSystem = UnitUtils.metric;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUnitPreference();
    _eventSubscription = EventBus().stream.listen((event) {
      if (event is AnalysisDeletedEvent || event is UserFollowEvent) {
        _loadUserData();
      }
      if (event is UnitsPreferenceChangedEvent) {
        setState(() {
          _unitSystem = event.units;
        });
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getProfile();
    try {
      final analyses = await _analysisService.getAnalyses();
      if (mounted) {
        setState(() {
          _userData = user;
          _analyses = analyses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userData = user;
          // _analyses remains empty or error handled
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load analysis history: ${e.toString()}'),
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

  Future<void> _goToEditProfile() async {
    if (_userData == null) return;
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(userData: _userData!),
      ),
    );
    if (updated == true) {
      await _loadUserData();
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
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
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Profile Header
                HomeHeader(userData: _userData),
                const SizedBox(height: 24),

                // Profile Image Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.grayDark,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      // Large Profile Image with red border
                      GestureDetector(
                        onTap: () async {
                          if (_userData == null) return;
                          final updated = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                userData: _userData!,
                              ),
                            ),
                          );
                          if (updated == true) {
                            _loadUserData();
                          }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 5,
                                ),
                                color: AppColors.grayLight,
                                image: _userData?['profilePicture'] != null &&
                                        _userData!['profilePicture'] != ''
                                    ? DecorationImage(
                                        image:
                                            NetworkImage(_userData!['profilePicture']),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _userData?['profilePicture'] == null ||
                                      _userData!['profilePicture'] == ''
                                  ? const Icon(Icons.person,
                                      size: 80, color: Colors.white)
                                  : null,
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nick name
                      Text(
                        _userData?['name'] ?? 'Nick name',
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
                      const SizedBox(height: 12),
                      if ((_userData?['bio'] ?? '').toString().isNotEmpty)
                        Text(
                          _userData!['bio'],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.grayLight,
                            fontSize: 13,
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
                            color: AppColors.grayDark,
                          ),
                          _buildStatColumn(
                              'Following', '${_userData?['following'] ?? 0}'),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.grayDark,
                          ),
                          _buildStatColumn(
                              'Avg. Score', '${_calculateAverageScore()}'),
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
                        // Calculate streak from analyses (fallback to user data if needed, but calculate is better if user data is stuck at 0)
                        value:
                            '${AnalysisService.calculateStreak(_analyses)} days',
                        iconColor: AppColors.fireOrange,
                        iconBgColor: AppColors.fireBackground,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StreakPage(
                                initialAnalyses: _analyses,
                              ),
                            ),
                          );
                        },
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
                        onTap: () {
                          if (widget.onNavigateToAnalysis != null) {
                            widget.onNavigateToAnalysis!();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(
                                  initialIndex: 2,
                                ),
                              ),
                            );
                          }
                        },
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
                                      date: DateFormat.yMMMd().format(
                                          DateTime.parse(
                                              analysis['createdAt'])),
                                      overallRating: overall,
                                      bodyPartRatings: bodyParts,
                                      adviceTitle: analysis['adviceTitle'] ??
                                          'Analysis Result',
                                      adviceDescription:
                                          analysis['advice'] ?? '',
                                      imageUrls: imageUrls,
                                      isMe: true,
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
                const SizedBox(height: 32),
                // Edit Profile and Settings buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildOutlineButton(
                        'Edit profile',
                        Icons.edit_outlined,
                        () async {
                          if (_userData != null) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProfilePage(userData: _userData!),
                              ),
                            );
                            if (result == true) {
                              _loadUserData();
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOutlineButton(
                        'Settings',
                        Icons.settings_outlined,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Logout Button
                OutlinedButton(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.grayDark,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        color: Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Log out',
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.grayDark,
        side: BorderSide(color: AppColors.grayLight, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.grayLight,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color iconBgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grayDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.grayLight,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

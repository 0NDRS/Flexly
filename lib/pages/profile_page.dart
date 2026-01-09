import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/services/analysis_service.dart';
import 'package:flexly/pages/login_page.dart';
import 'package:flexly/pages/analysis_detail_page.dart';
import 'package:intl/intl.dart';
import 'package:flexly/widgets/home/home_header.dart';
import 'package:flexly/pages/settings_page.dart';
import 'package:flexly/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _analysisService = AnalysisService();
  Map<String, dynamic>? _userData;
  List<dynamic> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                HomeHeader(userData: _userData),
                const SizedBox(height: 20),

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
                                  image: NetworkImage(
                                      _userData!['profilePicture']),
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
                              'Score', '${_userData?['score'] ?? 0}'),
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
                        label: 'Current Streak',
                        // Calculate streak from analyses (fallback to user data if needed, but calculate is better if user data is stuck at 0)
                        value:
                            '${AnalysisService.calculateStreak(_analyses)} days',
                        iconColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSmallCard(
                        icon: Icons.analytics_outlined,
                        label: 'Analytics Tracked',
                        value: '${_analyses.length}',
                        iconColor: Colors.blue,
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

                            return GestureDetector(
                              onTap: () {
                                final ratingsMap =
                                    analysis['ratings'] as Map<String, dynamic>;
                                final double overall =
                                    (ratingsMap['overall'] as num).toDouble();

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
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.grayLight,
                                  borderRadius: BorderRadius.circular(12),
                                  image: firstImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(firstImageUrl),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
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
        side: const BorderSide(color: AppColors.grayLight, width: 1.5),
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
  }) {
    return Container(
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
              color: AppColors.gray,
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/services/user_service.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/pages/user_profile_page.dart';

class UserSearchDelegate extends SearchDelegate {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.grayLight),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.white),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary,
        selectionHandleColor: AppColors.primary,
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.backgroundDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: AppColors.grayLight),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppColors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container(
        color: AppColors.backgroundDark,
        child: Center(
          child: Text(
            'Search for users...',
            style: AppTextStyles.body1.copyWith(color: AppColors.grayLight),
          ),
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<dynamic>>(
      future: _userService.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: AppTextStyles.body1.copyWith(color: AppColors.grayLight),
            ),
          );
        }

        return Container(
          color: AppColors.backgroundDark,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.gray,
                  backgroundImage: user['profilePicture'] != null &&
                          user['profilePicture'].isNotEmpty
                      ? NetworkImage(user['profilePicture'])
                      : null,
                  child: user['profilePicture'] == null ||
                          user['profilePicture'].isEmpty
                      ? const Icon(Icons.person, color: AppColors.grayLight)
                      : null,
                ),
                title: Text(
                  user['name'] ?? 'User',
                  style: AppTextStyles.body1.copyWith(color: AppColors.white),
                ),
                subtitle: Text(
                  '@${user['username'] ?? ''}',
                  style:
                      AppTextStyles.small.copyWith(color: AppColors.grayLight),
                ),
                onTap: () async {
                  final currentUser = await _authService.getUser();
                  if (currentUser != null &&
                      user['_id'] == currentUser['_id']) {
                    return;
                  }

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfilePage(userId: user['_id']),
                      ),
                    );
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

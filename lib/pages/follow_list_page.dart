import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flexly/services/user_service.dart';
import 'package:flexly/pages/user_profile_page.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/pages/profile_page.dart';

enum FollowListType { followers, following }

class FollowListPage extends StatefulWidget {
  final String userId;
  final FollowListType initialType;

  const FollowListPage({
    super.key,
    required this.userId,
    required this.initialType,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final UserService _userService = UserService();
  late FollowListType _currentType;
  List<dynamic>? _users;
  bool _isLoading = true;
  String? _error;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _loadCurrentUserId();
    _loadUsers();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      final userData = jsonDecode(userStr);
      setState(() {
        _currentUserId = userData['_id'];
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<dynamic> users;
      if (_currentType == FollowListType.followers) {
        users = await _userService.getFollowers(widget.userId);
      } else {
        users = await _userService.getFollowing(widget.userId);
      }
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentType == FollowListType.followers
            ? 'Followers'
            : 'Following'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _users!.isEmpty
                  ? Center(
                      child: Text(
                        _currentType == FollowListType.followers
                            ? 'No followers yet'
                            : 'Not following anyone',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users!.length,
                      itemBuilder: (context, index) {
                        final user = _users![index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.grayLight,
                            backgroundImage: user['profilePicture'] != null &&
                                    user['profilePicture'].toString().isNotEmpty
                                ? NetworkImage(user['profilePicture'])
                                : null,
                            child: user['profilePicture'] == null ||
                                    user['profilePicture'].toString().isEmpty
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(user['username'] ?? 'User'),
                          subtitle: Text(user['name'] ?? ''),
                          onTap: () async {
                            if (_currentUserId != null &&
                                user['_id'] == _currentUserId) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfilePage(),
                                ),
                              );
                            } else {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserProfilePage(userId: user['_id']),
                                ),
                              );
                            }
                            _loadUsers();
                          },
                        );
                      },
                    ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:flexly/pages/home.dart';
import 'package:flexly/services/auth_service.dart';
import 'package:flexly/services/notification_service.dart';
import 'package:flexly/pages/notifications_page.dart';
import 'package:flexly/services/event_bus.dart';
import 'dart:async';

class HomeHeader extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const HomeHeader({
    super.key,
    this.userData,
  });

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final _authService = AuthService();
  final _notificationService = NotificationService();
  Map<String, dynamic>? _userData;
  String? _profileImageUrl;
  bool _hasUnreadNotifications = false;
  StreamSubscription? _eventSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _userData = widget.userData;
      _profileImageUrl = widget.userData?['profilePicture'];
    } else {
      _loadUserData();
    }
    _checkNotifications();
    _eventSubscription = EventBus().stream.listen((event) {
      if (event is NotificationsReadEvent) {
        if (mounted) {
          setState(() {
            _hasUnreadNotifications = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _hasUnreadNotifications = notifications.any((n) => !n.read);
        });
      }
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }

  @override
  void didUpdateWidget(HomeHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userData != oldWidget.userData) {
      setState(() {
        _userData = widget.userData;
        _profileImageUrl = widget.userData?['profilePicture'];
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUser();
    if (mounted) {
      setState(() {
        _userData = user;
        _profileImageUrl = user?['profilePicture'];
      });
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(initialIndex: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _navigateToProfile(context),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayLight,
              border: Border.all(color: AppColors.primary, width: 2),
              image: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(_profileImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _profileImageUrl == null || _profileImageUrl!.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _navigateToProfile(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${_userData?['username'] ?? _userData?['name']?.split(' ')[0] ?? 'Friend'} 👋',
                style: AppTextStyles.caption1.copyWith(color: AppColors.white),
              ),
              Text(
                "Let's workout!",
                style: AppTextStyles.small.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsPage(),
              ),
            );
            // Refresh state when coming back
            _checkNotifications();
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grayDark,
              border: Border.all(color: AppColors.gray, width: 1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
                if (_hasUnreadNotifications)
                  Positioned(
                    top: 14,
                    right: 16,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

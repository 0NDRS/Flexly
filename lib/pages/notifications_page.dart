import 'package:flutter/material.dart';
import 'package:flexly/models/notification_model.dart';
import 'package:flexly/services/notification_service.dart';
import 'package:flexly/pages/user_profile_page.dart';
import 'package:flexly/services/event_bus.dart';
import 'package:flexly/theme/app_colors.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });

        _markAsRead();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAsRead() async {
    try {
      await _notificationService.markRead();
      EventBus().fire(NotificationsReadEvent());


    } catch (e) {
      debugPrint('Failed to mark notifications read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return NotificationTile(notification: notification);
                  },
                ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({super.key, required this.notification});

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}y ago';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UserProfilePage(userId: notification.sender.id),
            ),
          );
        },
        child: CircleAvatar(
          backgroundColor: AppColors.grayLight,
          backgroundImage: notification.sender.profilePicture != null &&
                  notification.sender.profilePicture!.isNotEmpty
              ? NetworkImage(notification.sender.profilePicture!)
              : null,
          child: notification.sender.profilePicture == null ||
                  notification.sender.profilePicture!.isEmpty
              ? const Icon(Icons.person, color: Colors.white)
              : null,
        ),
      ),
      title: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: notification.sender.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: ' started following you.'),
          ],
        ),
      ),
      subtitle: Text(
        _timeAgo(notification.createdAt),
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UserProfilePage(userId: notification.sender.id),
          ),
        );
      },
    );
  }
}

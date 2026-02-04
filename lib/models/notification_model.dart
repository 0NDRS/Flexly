class NotificationModel {
  final String id;
  final String recipient;
  final User sender;
  final String type;
  final bool read;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipient,
    required this.sender,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      recipient: json['recipient'],
      sender: User.fromJson(json['sender']),
      type: json['type'],
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class User {
  final String id;
  final String username;
  final String? profilePicture;

  User({required this.id, required this.username, this.profilePicture});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      profilePicture: json['profilePicture'],
    );
  }
}

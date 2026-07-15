import 'user.dart';

class AppChat {
  final int id;
  final String type;
  final AppUser? otherUser;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;

  AppChat({
    required this.id,
    required this.type,
    this.otherUser,
    this.lastMessageText,
    this.lastMessageAt,
    required this.unreadCount,
  });

  factory AppChat.fromJson(Map<String, dynamic> json) {
    return AppChat(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'PRIVATE',
      otherUser: json['otherUser'] != null
          ? AppUser.fromJson(json['otherUser'] as Map<String, dynamic>)
          : null,
      lastMessageText: json['lastMessageText'] as String?,
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'] as String)
          : null,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  AppChat copyWith({
    String? lastMessageText,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return AppChat(
      id: id,
      type: type,
      otherUser: otherUser,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  String get title => otherUser?.displayName ?? 'Чат #$id';
}

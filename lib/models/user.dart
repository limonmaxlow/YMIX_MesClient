class AppUser {
  final int id;
  final String username;
  final String displayName;
  final bool online;
  final DateTime? lastSeenAt;

  AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.online,
    this.lastSeenAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      username: json['username'] as String,
      displayName: json['displayName'] as String? ?? json['username'] as String,
      online: json['online'] as bool? ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.tryParse(json['lastSeenAt'] as String)
          : null,
    );
  }

  String get initial =>
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
}

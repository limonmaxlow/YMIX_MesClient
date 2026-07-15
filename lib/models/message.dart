class AppMessage {
  final int id;
  final int chatId;
  final int senderId;
  final String senderUsername;
  final String content;
  final String status;
  final DateTime sentAt;

  AppMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderUsername,
    required this.content,
    required this.status,
    required this.sentAt,
  });

  factory AppMessage.fromJson(Map<String, dynamic> json) {
    return AppMessage(
      id: json['id'] as int,
      chatId: json['chatId'] as int,
      senderId: json['senderId'] as int,
      senderUsername: json['senderUsername'] as String,
      content: json['content'] as String,
      status: json['status'] as String? ?? 'SENT',
      sentAt: DateTime.tryParse(json['sentAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

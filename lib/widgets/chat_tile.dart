import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';

class ChatTile extends StatelessWidget {
  final AppChat chat;
  final VoidCallback onTap;
  final Color avatarColor;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
    required this.avatarColor,
  });

  String _time(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final local = dt.toLocal();
    if (local.year == now.year && local.month == now.month && local.day == now.day) {
      return DateFormat('HH:mm').format(local);
    }
    return DateFormat('dd.MM').format(local);
  }

  @override
  Widget build(BuildContext context) {
    final initial = chat.otherUser?.initial ?? '#';
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: avatarColor,
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        chat.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        chat.lastMessageText ?? 'Нет сообщений',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _time(chat.lastMessageAt),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 6),
          if (chat.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${chat.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

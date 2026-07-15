import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
import '../../services/ws_service.dart';
import '../../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final AppChat chat;
  const ChatScreen({super.key, required this.chat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<AppMessage> _messages = []; // хранится в обратном порядке (новые сверху при reverse: true)
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WsService.instance.subscribeToChat(widget.chat.id);
    WsService.instance.onMessage = _handleIncoming;
  }

  @override
  void dispose() {
    WsService.instance.unsubscribeFromChat(widget.chat.id);
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    try {
      // getMessages возвращает страницу "сначала новые" — это то, что нужно
      // для reverse-ListView (индекс 0 = самое новое сообщение внизу экрана).
      final history = await ApiService.instance.getMessages(widget.chat.id);
      if (!mounted) return;
      setState(() => _messages
        ..clear()
        ..addAll(history));
      if (_messages.isNotEmpty) {
        await ApiService.instance.markRead(widget.chat.id, _messages.first.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleIncoming(AppMessage message) {
    if (message.chatId != widget.chat.id) return;
    if (!mounted) return;
    setState(() => _messages.insert(0, message));
    ApiService.instance.markRead(widget.chat.id, message.id);
  }

  Future<void> _send() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    WsService.instance.sendMessage(widget.chat.id, text);
    _messageCtrl.clear();
    // Сообщение придёт обратно через /topic/chat.{id} и добавится в _handleIncoming.
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = Session.instance.user;
    final other = widget.chat.otherUser;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accentBlue,
              child: Text(
                other?.initial ?? '#',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.chat.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    other?.online == true ? 'в сети' : 'не в сети',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.call_outlined),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? const Center(child: Text('Сообщений пока нет'))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMine = me != null && msg.senderId == me.id;
                          return MessageBubble(message: msg, isMine: isMine);
                        },
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.attach_file, color: Colors.grey.shade600),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageCtrl,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Сообщение',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            CircleAvatar(
              backgroundColor: AppColors.navy,
              child: IconButton(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



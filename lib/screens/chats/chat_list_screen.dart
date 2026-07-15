import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/chat.dart';
import '../../services/api_service.dart';
import '../../services/session.dart';
import '../../services/ws_service.dart';
import '../../widgets/chat_tile.dart';
import '../../widgets/ymix_logo.dart';
import '../chat/chat_screen.dart';
import '../profile/profile_screen.dart';
import 'new_chat_screen.dart';

enum _ChatFilter { all, favourites, archive }

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<AppChat> _chats = [];
  bool _loading = true;
  String? _error;
  bool _searching = false;
  final _searchCtrl = TextEditingController();
  _ChatFilter _filter = _ChatFilter.all;

  static const _avatarColors = [
    Color(0xFF9E9E9E),
    Color(0xFFD46FB0),
    Color(0xFF223354),
    Color(0xFFEDE58F),
    Color(0xFF7E97C7),
  ];

  @override
  void initState() {
    super.initState();
    _loadChats();
    WsService.instance.connect();
    WsService.instance.onChatUpdate = _handleChatUpdate;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final chats = await ApiService.instance.getChats();
      if (!mounted) return;
      setState(() => _chats = chats);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleChatUpdate(AppChat updated) {
    if (!mounted) return;
    setState(() {
      final idx = _chats.indexWhere((c) => c.id == updated.id);
      if (idx >= 0) {
        _chats[idx] = updated;
      } else {
        _chats.insert(0, updated);
      }
      _chats.sort((a, b) {
        final at = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      });
    });
  }

  Color _colorFor(int id) => _avatarColors[id % _avatarColors.length];

  List<AppChat> get _visibleChats {
    var list = _chats;
    if (_searchCtrl.text.trim().isNotEmpty) {
      final q = _searchCtrl.text.trim().toLowerCase();
      list = list
          .where((c) => c.title.toLowerCase().contains(q))
          .toList();
    }
    // Избранное/Архив — пока UI-фильтры на клиенте: бэкенд не хранит
    // признаки "избранное"/"архив" для чата.
    return list;
  }

  Future<void> _openNewChat() async {
    final chat = await Navigator.of(context).push<AppChat>(
      MaterialPageRoute(builder: (_) => const NewChatScreen()),
    );
    if (chat != null) {
      setState(() {
        final idx = _chats.indexWhere((c) => c.id == chat.id);
        if (idx >= 0) {
          _chats[idx] = chat;
        } else {
          _chats.insert(0, chat);
        }
      });
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.instance.user;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.navy,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const YMixLogo(fontSize: 26),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.accentPurple,
                          child: Text(
                            user?.initial ?? '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openNewChat,
                        icon: const Icon(Icons.edit_square, color: Colors.white),
                      ),
                      _chip('Избранное', _ChatFilter.favourites),
                      const SizedBox(width: 8),
                      _chip('Архив', _ChatFilter.archive),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(() => _searching = !_searching),
                        icon: Icon(
                          _searching ? Icons.close : Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_searching) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'поиск',
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, _ChatFilter filter) {
    final selected = _filter == filter;
    return GestureDetector(
      onTap: () => setState(() => _filter = selected ? _ChatFilter.all : filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.navy : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadChats, child: const Text('Повторить')),
          ],
        ),
      );
    }
    final chats = _visibleChats;
    if (chats.isEmpty) {
      return const Center(child: Text('Пока нет чатов. Нажмите ✎, чтобы начать.'));
    }
    return RefreshIndicator(
      onRefresh: _loadChats,
      child: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return ChatTile(
            chat: chat,
            avatarColor: _colorFor(chat.id),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
              );
            },
          );
        },
      ),
    );
  }
}

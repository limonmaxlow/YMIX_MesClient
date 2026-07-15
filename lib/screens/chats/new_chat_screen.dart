import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<AppUser> _results = [];
  bool _loading = false;

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _loading = true);
    try {
      final results = await ApiService.instance.searchUsers(query.trim());
      if (!mounted) return;
      setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openChat(AppUser user) async {
    setState(() => _loading = true);
    try {
      final chat = await ApiService.instance.createOrGetPrivateChat(user.username);
      if (!mounted) return;
      Navigator.of(context).pop(chat);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый чат')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Поиск по никнейму',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final user = _results[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accentBlue,
                    child: Text(user.initial,
                        style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user.displayName),
                  subtitle: Text('@${user.username}'),
                  onTap: () => _openChat(user),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

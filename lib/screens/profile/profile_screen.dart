import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/session.dart';
import '../../services/ws_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    WsService.instance.disconnect();
    await Session.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.instance.user;
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: BackButton(onPressed: () => Navigator.of(context).pop()),
            ),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.accentPurple,
              child: Text(
                user?.initial ?? '?',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.displayName ?? '',
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${user?.username ?? ''}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.all(20),
                child: ListView(
                  children: [
                    const Text(
                      'Настройки',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _settingsTile(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Приватность',
                      subtitle: 'Настройки видимости профиля',
                    ),
                    _settingsTile(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Уведомления',
                      subtitle: 'Управление оповещениями',
                    ),
                    _settingsTile(
                      context,
                      icon: Icons.palette_outlined,
                      title: 'Внешний вид',
                      subtitle: 'Темы, шрифты, иконки, фон',
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: const Text('Выйти',
                            style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: const Color(0xFFF3F3F5),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.navy,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '«$title» пока не реализовано на бэкенде — раздел для будущего API.',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

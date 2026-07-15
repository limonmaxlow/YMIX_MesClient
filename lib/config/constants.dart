/// Настройки подключения к Java Spring Boot бэкенду (messenger-backend).
///
/// ВАЖНО: поменяйте [apiHost] под ваше окружение:
///  - Android-эмулятор -> 10.0.2.2 (алиас "localhost" хост-машины)
///  - iOS-симулятор / desktop / web -> localhost
///  - Реальное устройство -> IP-адрес компьютера в локальной сети (например 192.168.1.50)
class AppConfig {
  AppConfig._();

  /// Хост и порт бэкенда (см. server.port в application.yml, по умолчанию 8080).
  static const String apiHost = 'localhost';
  static const int apiPort = 8080;

  static String get httpBase => 'http://$apiHost:$apiPort';

  /// Чистый STOMP-эндпоинт без SockJS — соответствует /ws в WebSocketConfig.java
  static String get wsUrl => 'ws://$apiHost:$apiPort/ws';

  static const String apiAuthRegister = '/api/auth/register';
  static const String apiAuthLogin = '/api/auth/login';
  static const String apiChats = '/api/chats';
  static const String apiUsersSearch = '/api/users/search';
}

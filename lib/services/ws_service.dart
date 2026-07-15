import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../config/constants.dart';
import '../models/chat.dart';
import '../models/message.dart';
import 'session.dart';

typedef MessageHandler = void Function(AppMessage message);
typedef ChatUpdateHandler = void Function(AppChat chat);

/// Обёртка над STOMP-соединением к /ws (WebSocketConfig.java, raw STOMP без SockJS).
///
/// Соответствует ChatWebSocketController.java на бэкенде:
///  - SEND    /app/chat.send            body: { chatId, content }
///  - SUB     /topic/chat.{chatId}      -> MessageDto — открытая переписка
///  - SUB     /user/queue/chats         -> ChatDto     — обновление списка чатов
class WsService {
  WsService._();
  static final WsService instance = WsService._();

  StompClient? _client;
  bool _connected = false;

  final Set<int> _chatSubscriptions = {};
  MessageHandler? onMessage;
  ChatUpdateHandler? onChatUpdate;
  void Function()? onConnected;

  bool get isConnected => _connected;

  void connect() {
    final token = Session.instance.token;
    if (token == null) return;

    _client = StompClient(
      config: StompConfig(
        url: AppConfig.wsUrl,
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) {
          _connected = false;
        },
        onStompError: (StompFrame frame) {
          _connected = false;
        },
        onDisconnect: (StompFrame frame) {
          _connected = false;
        },
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 4),
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame frame) {
    _connected = true;

    // Личная очередь: обновления списка чатов (последнее сообщение / счётчик).
    _client!.subscribe(
      destination: '/user/queue/chats',
      callback: (StompFrame f) {
        if (f.body == null) return;
        final json = jsonDecode(f.body!) as Map<String, dynamic>;
        onChatUpdate?.call(AppChat.fromJson(json));
      },
    );

    // Повторно подписываемся на все чаты, открытые до реконнекта.
    for (final chatId in _chatSubscriptions) {
      _subscribeChatTopic(chatId);
    }

    onConnected?.call();
  }

  void subscribeToChat(int chatId) {
    _chatSubscriptions.add(chatId);
    if (_connected) _subscribeChatTopic(chatId);
  }

  void _subscribeChatTopic(int chatId) {
    _client?.subscribe(
      destination: '/topic/chat.$chatId',
      callback: (StompFrame f) {
        if (f.body == null) return;
        final json = jsonDecode(f.body!) as Map<String, dynamic>;
        onMessage?.call(AppMessage.fromJson(json));
      },
    );
  }

  void unsubscribeFromChat(int chatId) {
    _chatSubscriptions.remove(chatId);
  }

  void sendMessage(int chatId, String content) {
    _client?.send(
      destination: '/app/chat.send',
      body: jsonEncode({'chatId': chatId, 'content': content}),
    );
  }

  void disconnect() {
    _connected = false;
    _chatSubscriptions.clear();
    _client?.deactivate();
    _client = null;
  }
}

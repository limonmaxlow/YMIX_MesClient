<div align="center">

# 📱 YMIX_MesClient

**Flutter-клиент мессенджера YMix**

Flutter · Dart · STOMP/WebSocket

</div>

---

## 📖 О проекте

YMIX_MesClient — кроссплатформенный клиент на Flutter, работающий в паре
с бэкендом `YMIX_MesServer`.

**Возможности:**

- 🔐 Авторизация по JWT, сессия сохраняется между запусками
- 💬 Список чатов и поиск пользователей
- 📜 История переписки с пагинацией
- ⚡ Обмен сообщениями в реальном времени через STOMP/WebSocket

---

## 🏗 Архитектура

| Папка | Назначение |
|---|---|
| `config/` | адрес бэкенда, тема приложения |
| `models/` | User, Chat, Message |
| `services/` | `api_service` (REST), `ws_service` (STOMP/WebSocket), `session` (JWT) |
| `screens/` | auth, chats, chat, profile, splash |
| `widgets/` | chat_tile, message_bubble, ymix_logo, blob_background |

`api_service` обращается к REST-эндпоинтам бэкенда, а `ws_service` держит
STOMP-соединение и подписки для сообщений в реальном времени. JWT из
`session` подставляется как в REST-запросы, так и в заголовок при STOMP
CONNECT.

---

## 🛠 Стек

- Flutter (Dart)
- `http`
- `stomp_dart_client`
- `provider`
- `shared_preferences`
- `intl`

---

## 🚀 Запуск

Понадобится установленный Flutter SDK и запущенный бэкенд.

**1. Сгенерировать платформенные каталоги**

```bash
flutter create ymix_app
cd ymix_app
```

**2. Подставить присланные lib/ и pubspec.yaml**

```bash
rm -rf lib
cp -r /путь/до/присланного/lib .
cp /путь/до/присланного/pubspec.yaml .
```

**3. Установить зависимости и запустить**

```bash
flutter pub get
flutter run
```

**Перед запуском** укажите адрес бэкенда в `lib/config/constants.dart`
(`apiHost`, `apiPort`):

| Платформа | Адрес |
|---|---|
| Android-эмулятор | `10.0.2.2` |
| Desktop / iOS-симулятор / web | `localhost` |
| Реальное устройство | IP компьютера в локальной сети |

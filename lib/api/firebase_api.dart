import 'package:chat/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // экзепляр класса Firebase Messaging
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // инициализация уведомлений
  Future<void> initNotification() async {
    // запрос разрешения у пользователя
    await _firebaseMessaging.requestPermission();

    // токен обмена сообщениями 
    final fCMToken = await _firebaseMessaging.getToken();

    // print token
    print('Token: $fCMToken');
  }

  // обработка полученных сообщений
  void handleMessage(RemoteMessage? message) {
    if(message == null) {
      return;
    }
    navigatorKey.currentState?.pushNamed('/chat', arguments: message);
  }

  // инициализация фоновых настроек
  Future initPushNotifications() async {
    // обработать уведомление, если приложение было закрыто, а теперь открыто
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // приклепляем прослушиватель событий, когда уведомление открывает приложение
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
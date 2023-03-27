import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vdotok_stream_example/firebase_options.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling a background message ${message.messageId}');
}

class PushNotificationService {
  FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future initialize() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    // FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    //   print('Handling a background message ${message.messageId}');
    // });
    // Get the token
    await getToken();
  }

  Future<String?> getToken() async {
    String? token = await _fcm.getToken();
    print('Token: 44 $token');
    return token;
  }
}

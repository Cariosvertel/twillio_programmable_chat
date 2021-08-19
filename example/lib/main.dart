import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:twilio_programmable_chat_example/debug.dart';
import 'package:twilio_programmable_chat_example/join/join_page.dart';
import 'package:twilio_programmable_chat_example/shared/services/backend_service.dart';

void main() async {
  Debug.enabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  _configureNotifications();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(TwilioProgrammableChatExample());
}

//#region Android Notification Handling
// iOS SDK uses APNs and handles notifications internally

void _configureNotifications() {
  if (Platform.isAndroid) {
    FlutterLocalNotificationsPlugin().initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('icon_192'),
      ),
    );
    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
  }
}

void onMessage(RemoteMessage message) {
  print('Main::FirebaseMessaging.onMessage => ${message.data}');
}

void onMessageOpenedApp(RemoteMessage message) {
  print('Main::FirebaseMessaging.onMessageOpenedApp => ${message.data}');
}

Future onBackgroundMessage(RemoteMessage message) async {
  print('Main::FirebaseMessaging.onBackgroundMessage => ${message.data}');
  final data = Map<String, dynamic>.from(message.data);
  if (data['message_index'] != null && data['channel_title'] != null && data['twi_body'] != null) {
    await FlutterLocalNotificationsPlugin().show(
      int.parse(data['message_index']),
      data['channel_title'],
      data['twi_body'],
      NotificationDetails(
        android: AndroidNotificationDetails(
          '0',
          'Chat',
          'Twilio Chat Channel 0',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }
}
//#endregion

class TwilioProgrammableChatExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<BackendService>(
      create: (_) => TwilioFirebaseFunctions.instance,
      child: MaterialApp(
        title: 'Twilio Programmable Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.blue,
            textTheme: TextTheme(
              headline6: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        home: JoinPage(),
      ),
    );
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'homescreen.dart';

class LocalNotification {
  static BuildContext context;
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> setNotification(String title) async{


   Future<void> onSelectNotification(String str) {
     Navigator.push(context,MaterialPageRoute(
       builder: (context) => HomeScreen(HomeScreen.globalUser),
     )
     );


    }

   flutterLocalNotificationsPlugin.initialize(
       InitializationSettings(android:AndroidInitializationSettings('icon'),
           iOS:IOSInitializationSettings(),
           macOS: null),
       onSelectNotification: onSelectNotification
   );
    var notificationTime = DateTime.now().add(Duration(seconds: 10));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel id',
      'channel name',
      'channel description',
      icon: 'icon',
      largeIcon: DrawableResourceAndroidBitmap('icon'),
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
      macOS: null,
    );



    await flutterLocalNotificationsPlugin.schedule(
      1,
      'SuMo',
      "${title} is in the upcoming list, Let's check it out" ,
      notificationTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: false,
    );

  }

}

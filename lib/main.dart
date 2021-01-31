import 'package:flutter/material.dart';
import 'local_notification.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'loading.dart';
import 'databaseHelper.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';



void callbackDispatcher() {
  Workmanager.executeTask((taskName, inputData) async {

    final dbHelper = DatabaseHelper.instance;

    var data =  await movie.fetchMovie("upcoming");
    var DB = await dbHelper.queryAllRows(DatabaseHelper.tableUpcoming);
    if(DB.length>0) {
      for (int index = 0; index < 6; index++) {
        bool tf = await dbHelper.find(
            data[index]["id"].toString(), DatabaseHelper.tableUpcoming,
            DatabaseHelper.columnMovieID);
        if (tf) {
          await LocalNotification.setNotification(data[index]["title"]);
          break;
        }
      }
    }
    return Future.value(true);
  });
}
 sendNotification() async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        id: 100,
        channelKey: "daily notification channel",
        title: "Let's explore!!",
        body: "Do you want to discover new movies ?",
        notificationLayout: NotificationLayout.BigText,
        largeIcon: "https://i.ibb.co/XznLm6p/icon.png",
        showWhen: true,
        autoCancel: true,
        payload: {
          "secret": "Awesome Notifications Rocks!"
        }
    ),
    actionButtons: [
      NotificationActionButton(
          key: "0",
          label: "Dismiss",
          icon: null,
          buttonType: ActionButtonType.KeepOnTop // ActionButtonType.DisabledAction
      ),

      /*It should be 'Disabled' action. However it does not work now, so changed with keep on top*/

      NotificationActionButton(
        key: "1",
        label: "Go to App",
        icon: null,
        buttonType: ActionButtonType.Default,
      ),

    ],
  );

}
void sendNotif(){
sendNotification();

}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await Workmanager.initialize(callbackDispatcher);
  await Workmanager.registerPeriodicTask("Background Task", "Background Task",
      frequency: Duration(minutes: 30),
      initialDelay: Duration(minutes: 30));
  await Firebase.initializeApp();
  initializeApp();
  final int helloAlarmID = 0;
  await AndroidAlarmManager.initialize();

  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => login(),
    },
    debugShowCheckedModeBanner: false,
  ));
  await AndroidAlarmManager.periodic(const Duration(hours: 18), helloAlarmID, sendNotif);
}

void initializeApp() async{
  AwesomeNotifications().initialize(
      'resource://drawable/icon', // this makes you use your default icon, if you haven't one
      [
        NotificationChannel(
            channelKey: 'daily notification channel',
            channelName: 'daily notifications',
            channelDescription: 'Notification channel for daily notificaiton',
            defaultColor: Colors.red,
            ledColor: Colors.yellow,
        )
      ]
  );
}



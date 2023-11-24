
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as u;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';
import 'package:makaiapp/controllers/user_controller.dart';
import 'package:makaiapp/screens/auth/splash_screen.dart';
import 'package:makaiapp/screens/home/notifications.dart';
import 'package:makaiapp/screens/messages/conversations.dart';
import 'package:makaiapp/services/authentication_service.dart';
import 'package:makaiapp/services/booking_service.dart';
import 'package:makaiapp/services/dialog_service.dart';
import 'package:makaiapp/services/dynamic_link_service.dart';
import 'package:makaiapp/services/messages_service.dart';
import 'package:makaiapp/services/misc_service.dart';
import 'package:makaiapp/services/notification_service.dart';
import 'package:makaiapp/services/permissions_service.dart';
import 'package:makaiapp/services/storage_service.dart';
import 'package:makaiapp/services/user_service.dart';
import 'package:makaiapp/services/validator_service.dart';
import 'package:makaiapp/services/vessel_service.dart';
import 'package:makaiapp/utils/constants.dart';
import 'package:makaiapp/utils/preferences.dart';
import 'package:makaiapp/widgets/custom_button.dart';
import 'package:makaiapp/widgets/empty_box.dart';
import 'package:passbase_flutter/passbase_flutter.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  final userController = Get.find<UserController>();
  final userService = Get.find<UserService>();
  bool showNotifications = false;
  if (message.data['type'] == 'transactions' && userController.currentUser.value.transactionNotifications!) showNotifications = true;
  if (message.data['type'] == 'message' && userController.currentUser.value.messageNotifications!) showNotifications = true;
  if (message.data['type'] == 'vesselBookingRequest' && userController.currentUser.value.bookingNotifications!) showNotifications = true;
  if (message.data['type'] == 'vesselBookingResponse' && userController.currentUser.value.bookingNotifications!) showNotifications = true;
  if (message.data['type'] == 'general' && userController.currentUser.value.generalNotifications!) showNotifications = true;
  if (message.data['type'] == 'addCrew' && userController.currentUser.value.generalNotifications!) showNotifications = true;
  if (message.data['type'] == 'addCaptain' && userController.currentUser.value.generalNotifications!) showNotifications = true;
  if (message.data['type'] == 'verification') {
    showNotifications = true;
    await userService.getCurrentUser();
  }
  if (message.notification != null) {
    showNotification(message.notification as RemoteNotification); // Passing non-nullable notification
  }
}

showNotification(RemoteNotification notification) async {
  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        color: primaryColor,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        subText: notification.body,
      ),
      iOS: DarwinNotificationDetails(
        subtitle: notification.body,
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(Phoenix(child: MyApp()));

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final double textSize = 15;
  final double buttonTextSize = 15;

  RxBool authenticated = false.obs;
  RxBool isLoading = true.obs;

  @override
  void initState() {
    addServices();
    super.initState();

    FirebaseMessaging.instance.getInitialMessage();

    //foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      //AndroidNotification android = message.notification?.android;
      //   AppleNotification apple = message.notification?.apple;
      if (notification != null) {
        final userController = Get.find<UserController>();

        bool showNotifications = false;
        if (message.data['type'] == 'transactions' && userController.currentUser.value.transactionNotifications!) showNotifications = true;
        if (message.data['type'] == 'message' && userController.currentUser.value.messageNotifications!) showNotifications = true;
        if (message.data['type'] == 'vesselBookingRequest' && userController.currentUser.value.bookingNotifications!) showNotifications = true;
        if (message.data['type'] == 'vesselBookingResponse' && userController.currentUser.value.bookingNotifications!) showNotifications = true;
        if (message.data['type'] == 'general' && userController.currentUser.value.generalNotifications!) showNotifications = true;
        if (message.data['type'] == 'addCrew' && userController.currentUser.value.generalNotifications!) showNotifications = true;
        if (message.data['type'] == 'addCaptain' && userController.currentUser.value.generalNotifications!) showNotifications = true;
        if (message.data['type'] == 'verification') {
          showNotifications = true;
          final userService = Get.find<UserService>();
          await userService.getCurrentUser();
        }
        if (showNotifications) showNotification(message.notification as RemoteNotification);
      }
    });

    //tap on notification and app minimized
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      if (message.data['type'] == 'message') Get.to(() => Conversations());
      if (message.data['type'] == 'vesselBookingRequest') Get.to(() => Notifications());
      if (message.data['type'] == 'vesselBookingResponse') Get.to(() => Notifications());
      if (message.data['type'] == 'verification') {
        final userService = Get.find<UserService>();
        await userService.getCurrentUser();
      }
    });
    checkBiometrics();
  }

  checkBiometrics() async {
    if (u.FirebaseAuth.instance.currentUser != null) {
      bool biometric = await Preferences.getBiometricStatus();
      if (biometric) {
        final authService = Get.find<AuthService>();
        authenticated.value = await authService.authenticate();
      } else
        authenticated.value = true;
      isLoading.value = false;
    } else {
      authenticated.value = true;
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    PassbaseSDK.initialize(publishableApiKey: "cmKroKAccXWHuGIe4SlJ7OHz66TdIk5WBt0b309I8y98uNg5Sgi7ZoW9Qg6stCgK", customerPayload: '');
    return GetMaterialApp(
    builder: (BuildContext context, Widget? child) { // Fixed: accept Widget?
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        data: data.copyWith(textScaleFactor: 1),
        child: child ?? SizedBox.shrink(), // child can be null, so we accept Widget?
      );
    },
      title: 'Makai App',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade200,
        fontFamily: 'Font2',
        primaryColor: primaryColor,
        brightness: Brightness.light,
        cardTheme: CardTheme(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        dialogTheme: DialogTheme(titleTextStyle: darkTextStyle(buttonTextSize * 1.25), contentTextStyle: darkTextStyle(textSize)),
        textTheme: TextTheme(titleLarge: darkTextStyle(textSize), bodyMedium: darkTextStyle(textSize)),
        appBarTheme: AppBarTheme(centerTitle: true, color: primaryColor, elevation: 0, iconTheme: IconThemeData(color: Colors.white), titleTextStyle: lightTextStyle(textSize * 1.25)),
        tabBarTheme: TabBarTheme(labelColor: primaryColor, indicatorSize: TabBarIndicatorSize.label, unselectedLabelColor: Colors.grey, labelStyle: darkTextStyle(textSize)),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: primaryColor, type: BottomNavigationBarType.fixed, selectedItemColor: Colors.white, unselectedItemColor: Colors.white38),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(textStyle: MaterialStateProperty.all(TextStyle(fontSize: buttonTextSize)), shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), foregroundColor: MaterialStateProperty.all(primaryColor), minimumSize: MaterialStateProperty.all(Size(45, 45)))),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(backgroundColor: MaterialStateProperty.all(primaryColor), textStyle: MaterialStateProperty.all(TextStyle(color: Colors.white, fontSize: buttonTextSize, fontWeight: FontWeight.bold, letterSpacing: 1.25)), shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), minimumSize: MaterialStateProperty.all(Size(double.infinity, 45)))),
        inputDecorationTheme: InputDecorationTheme(border: inputBorder(Colors.grey.shade300), focusedBorder: inputBorder(Colors.grey.shade300), enabledBorder: inputBorder(Colors.grey.shade300), errorBorder: inputBorder(Colors.grey.shade300), disabledBorder: inputBorder(Colors.grey.shade300), hintStyle: TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white, contentPadding: EdgeInsets.only(left: 20)), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(background: Colors.grey.shade200),
      ),
      debugShowCheckedModeBanner: false,
      home: Obx(() {
        return isLoading.value
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : authenticated.value
                ? SplashScreen()
                : Scaffold(
                    appBar: AppBar(systemOverlayStyle: SystemUiOverlayStyle.dark, backgroundColor: Colors.transparent),
                    body: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EmptyBox(text: 'Biometric authentication failed.'),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            child: CustomButton(text: 'Try again', function: () => Phoenix.rebirth(context)),
                          ),
                        ],
                      ),
                    ),
                  );
      }),
    );
  }
}

inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(width: 1, color: color),
  );
}

darkTextStyle(double textSize) {
  return TextStyle(
    color: primaryColor,
    fontFamily: 'Font2',
    fontSize: textSize,
  );
}

lightTextStyle(double textSize) {
  return TextStyle(
    color: Colors.white,
    fontFamily: 'Font2',
    fontSize: textSize,
    fontWeight: FontWeight.bold,
  );
}

addServices() {
  Get.put(StorageService());
  Get.put(UserController());
  Get.put(UserService());
  Get.put(DialogService());
  Get.put(AuthService());
  Get.put(ValidatorService());
  Get.put(NotificationService());
  Get.put(MessageService());
  Get.put(PermissionsService());
  Get.put(DynamicLinkService());
  Get.put(VesselService());
  Get.put(MiscService());
  Get.put(BookingService());
}

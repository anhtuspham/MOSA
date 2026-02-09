import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/firebase_options.dart';
import 'package:mosa/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:mosa/services/database_service.dart';
import 'package:mosa/services/fcm_service.dart';
import 'package:mosa/utils/notification_helper.dart';
import 'package:toastification/toastification.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  // Initialize FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FCMService.instance.initialize();

  // Initialize notification helper
  await NotificationHelper.initialize();

  // await DatabaseService().initializeDatabase(clearExisting: true);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ToastificationWrapper(
        config: ToastificationConfig(
          marginBuilder:
              (context, alignment) => EdgeInsets.fromLTRB(0, 16, 0, 110),
          alignment: Alignment.center,
          itemWidth: 440,
          animationDuration: Duration(milliseconds: 500),
          blockBackgroundInteraction: false,
        ),
        child: MaterialApp.router(
          title: 'Finance Tracker',
          locale: Locale('vi', 'VN'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('vi', 'VN')],
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          routerConfig: goRouter,
        ),
      ),
    );
  }
}

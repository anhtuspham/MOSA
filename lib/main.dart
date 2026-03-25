import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mosa/firebase_options.dart';
import 'package:mosa/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosa/services/database_service.dart';
import 'package:mosa/services/fcm_service.dart';
import 'package:mosa/utils/notification_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:mosa/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database
  tz.initializeTimeZones();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
    realtimeClientOptions: RealtimeClientOptions(logLevel: RealtimeLogLevel.info),
    storageOptions: StorageClientOptions(retryAttempts: 10),
  );

  // Initialize FCM
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await FCMService.instance.initialize();

  // Initialize notification helper
  await NotificationHelper.initialize();

  await DatabaseService().initializeDatabase(clearExisting: true);

  runApp(ProviderScope(child: const MyApp()));
}

final supabase = Supabase.instance.client;

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeProvider);
    final themeMode = themeModeAsync.value ?? ThemeMode.system;

    return ScreenUtilInit(
      designSize: const Size(392, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ToastificationWrapper(
        config: ToastificationConfig(
          marginBuilder: (context, alignment) => EdgeInsets.fromLTRB(0, 16, 0, 110),
          alignment: Alignment.center,
          itemWidth: 440,
          animationDuration: Duration(milliseconds: 500),
          blockBackgroundInteraction: false,
        ),
        child: MaterialApp.router(
          title: 'Mosa',
          locale: Locale('vi', 'VN'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('en'), Locale('vi', 'VN')],
          debugShowCheckedModeBanner: false,
          theme: FlexThemeData.light(scheme: FlexScheme.flutterDash),
          darkTheme: FlexThemeData.dark(scheme: FlexScheme.flutterDash),
          themeMode: themeMode,
          routerConfig: goRouter,
        ),
      ),
    );
  }
}

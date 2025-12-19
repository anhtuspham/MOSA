import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosa/services/database_service.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Clear database to start fresh - this now deletes the entire database file
  // await DatabaseService().clearDatabase();

  // The database will be created automatically on first access
  // with tables and seeded wallets from onCreate callback

  // Optionally import transactions if needed:
  // await DatabaseService().importTransactionsFromAssets('assets/data/transactions.json');

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
            fontFamily: 'EuclidCircularA',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
            useMaterial3: true,
          ),
          routerConfig: goRouter,
        ),
      ),
    );
  }
}

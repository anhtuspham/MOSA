import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/router/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mosa/services/database_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // await DatabaseService().clearDatabase();

  // await DatabaseService().importDatabaseFromAssets('assets/data/transactions.json');

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        title: 'Finance Tracker',
        locale: Locale('vi', 'VN'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'),
          Locale('vi', 'VN'),
        ],
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'EuclidCircularA',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          useMaterial3: true,
        ),
        routerConfig: goRouter,
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/providers/date_filter_provider.dart';
import 'package:mosa/providers/transaction_provider.dart';
import 'package:mosa/router/app_router.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(create: (context) => DateFilterProvider(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(392, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      child: ChangeNotifierProvider(
        create: (_) => TransactionProvider()..loadTransaction(),
        child: MaterialApp.router(
          title: 'Finance Tracker',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'EuclidCircularA', colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue), useMaterial3: true),
          routerConfig: goRouter,
        ),
      ),
    );
  }
}

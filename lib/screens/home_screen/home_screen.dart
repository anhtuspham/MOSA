import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/screens/home_screen/income_screen.dart';

import '../../widgets/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào!', style: TextStyle(fontSize: 12.sp)),
              Text('Pham Anh Tu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
            ],
          ),
          leading: Container(
            margin: EdgeInsets.only(left: 8.w),
            child: CircleAvatar(radius: 20, backgroundColor: Colors.blueAccent, child: Text('P')),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
          actions: [
            Icon(Icons.sync, color: Colors.white),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications, color: Colors.white, size: 28),
                Positioned(
                  right: -1,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                    child: Text(
                      '3',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: TabBar(
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelStyle: TextStyle(color: Colors.white),
            labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            tabs: [
              Tab(child: Text('Tất cả')),
              Tab(child: Text('Thu nhập ')),
              Tab(child: Text('Chi tiêu')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Column(children: [Icon(Icons.analytics), Text('Không có dữ liệu')])),
            IncomeScreen(),
            Center(child: Text('Tab 3')),
          ],
        ),
      ),
    );
  }
}

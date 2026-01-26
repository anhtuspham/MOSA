import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/router/app_routes.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/category_grid_view.dart';
import 'package:mosa/widgets/item_widget.dart';

class SettingsShellScreen extends StatelessWidget {
  const SettingsShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xin chào!', style: TextStyle(fontSize: 12.sp)),
            Text(
              'Pham Anh Tu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
            ),
          ],
        ),
        toolbarHeight: 60,
        leading: Container(
          margin: EdgeInsets.only(left: 8.w),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.thirdBlue,
            child: Text('P'),
          ),
        ),
        actionsPadding: EdgeInsets.symmetric(horizontal: 12.w),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 28),
              Positioned(
                right: -1,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
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
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.goldColor,
                AppColors.lightGoldColor,
                AppColors.lighterGoldColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppColors.surface),
              child: Column(
                children: [
                  Text(
                    'Tính năng',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  CategoryGridView(
                    numberItemPerPage: 3,
                    categories: [
                      ItemWidget(
                        itemId: '1',
                        iconPath: AppIcons.interface,
                        name: 'Giao diện',
                      ),
                      ItemWidget(
                        itemId: '2',
                        iconPath: AppIcons.sampleRecord,
                        name: 'Ghi chép mẫu',
                      ),
                      ItemWidget(
                        itemId: '3',
                        iconPath: AppIcons.categoryRecord,
                        name: 'Hạng mục thu chi',
                      ),
                      ItemWidget(
                        itemId: '4',
                        iconPath: AppIcons.scanBill,
                        name: 'Trích xuất hóa đơn',
                      ),
                      ItemWidget(
                        itemId: '5',
                        iconPath: AppIcons.shopList,
                        name: 'Danh sách mua sắm',
                      ),
                      ItemWidget(
                        itemId: '6',
                        iconPath: AppIcons.limitTransaction,
                        name: 'Hạn mức thu/chi',
                      ),
                      ItemWidget(
                        itemId: '7',
                        iconPath: AppIcons.debtTracking,
                        onTap: () {
                          log('hello');
                          context.push(AppRoutes.loanTracking);
                        },
                        name: 'Theo dõi vay nợ',
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

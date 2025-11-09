import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/custom_list_tile.dart';

class AccountTabScreen extends StatefulWidget {
  const AccountTabScreen({super.key});

  @override
  State<AccountTabScreen> createState() => _AccountTabScreenState();
}

class _AccountTabScreenState extends State<AccountTabScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.secondary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng tiền', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('3.697.530đ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomListTile(
                  leading: Image.asset(AppIcons.logoMbBank, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoCash, width: 30),
                  title: Text('Tiền mặt', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoMomo, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
                CustomListTile(
                  leading: Image.asset(AppIcons.logoZalopay, width: 30),
                  title: Text('Mb bank', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                  subTitle: Text('913.024đ'),
                  trailing: IconButton(onPressed: null, icon: Icon(Icons.more_vert, color: AppColors.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

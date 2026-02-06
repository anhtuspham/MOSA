import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';
import 'package:mosa/utils/app_icons.dart';
import 'package:mosa/widgets/progress_info_item.dart';

class AccumulatedTabScreen extends StatefulWidget {
  const AccumulatedTabScreen({super.key});

  @override
  State<AccumulatedTabScreen> createState() => _AccumulatedTabScreenState();
}

class _AccumulatedTabScreenState extends State<AccumulatedTabScreen> {
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
              Text(
                'Tổng tiền',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              Text(
                '3.697.530đ',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ProgressInfoItem(
                  leadingIcon: Image.asset(AppIcons.moneyBag, width: 20),
                  title: Text(
                    'Tích lũy tiền sinh hoạt',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    '30.000.000đ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  currentProgress: 0.4,
                  linearColors: AppColors.primary,
                  actionIcon: Icons.more_vert,
                  subTitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Còn 286 ngày',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      Text(
                        'Cần thêm 18.245.163đ',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

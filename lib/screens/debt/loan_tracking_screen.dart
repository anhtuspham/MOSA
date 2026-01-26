import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mosa/widgets/common_scaffold.dart';
import 'package:mosa/widgets/section_container.dart';

import '../../utils/app_colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/progress_info_item.dart';

class LoanTrackingScreen extends StatefulWidget {
  const LoanTrackingScreen({super.key});

  @override
  State<LoanTrackingScreen> createState() => _LoanTrackingScreenState();
}

class _LoanTrackingScreenState extends State<LoanTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: Text("Theo dõi vay nợ"),
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: const [Icon(Icons.search)],
      appBarBackgroundColor: AppColors.background,
      tabs: [Tab(text: "Cho vay"), Tab(text: "Còn Nợ")],
      children: [loanTrackingContent('Cần thu'), loanTrackingContent('Còn nợ')],
    );
  }

  Widget loanTrackingContent(String typeLoan) {
    return SectionContainer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          ProgressInfoItem(
            leadingIcon: Icon(Icons.help),
            title: Text(typeLoan),
            currentProgress: 0.8,
            linearColors: AppColors.chartColors.first,
            trailing: Row(
              children: [Text(Helpers.formatCurrency(100000000), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp))],
            ),
            bottomContent: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đã thu'),
                    Text(Helpers.formatCurrency(100000000), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ],
                ),
                Column(
                  children: [
                    Text('Tổng cho vay'),
                    Text(Helpers.formatCurrency(100000000), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

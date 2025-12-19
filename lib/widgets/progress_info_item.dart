import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressInfoItem extends StatelessWidget {
  final Widget leadingIcon;
  final Widget title;
  final Widget? trailing;
  final double? currentProgress;
  final Color linearColors;
  final IconData forwardIcon;
  final Widget? subTitle;
  const ProgressInfoItem({
    super.key,
    required this.leadingIcon,
    required this.title,
    this.trailing,
    this.currentProgress,
    this.linearColors = Colors.red,
    this.forwardIcon = Icons.arrow_forward_ios_rounded,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    leadingIcon,
                    SizedBox(width: 8.w),
                    Expanded(child: title),
                    SizedBox(width: 8.w),
                    trailing ?? SizedBox(),
                  ],
                ),
                const SizedBox(height: 12),
                LinearPercentIndicator(
                  padding: EdgeInsets.zero,
                  lineHeight: 7.0,
                  percent: currentProgress ?? 0,
                  barRadius: Radius.circular(20),
                  progressColor: linearColors,
                ),
                const SizedBox(height: 12),
                subTitle ?? SizedBox(),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(forwardIcon, size: 16, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

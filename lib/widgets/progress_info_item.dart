import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosa/config/section_container_config.dart';
import 'package:mosa/widgets/section_container.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressInfoItem extends StatelessWidget {
  final Widget? leadingIcon;
  final Widget title;
  final Widget? trailing;
  final double? currentProgress;
  final Color linearColors;
  final IconData? actionIcon;
  final Widget? subTitle;
  final Widget? bottomContent;

  const ProgressInfoItem({
    super.key,
    this.leadingIcon,
    required this.title,
    this.trailing,
    this.currentProgress,
    this.linearColors = Colors.red,
    this.actionIcon,
    this.subTitle,
    this.bottomContent,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      config: SectionContainerConfig.compact,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        leadingIcon ?? SizedBox(),
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
              if (actionIcon != null) ...[
                const SizedBox(width: 10),
                Icon(actionIcon, size: 16, color: Colors.grey[700]),
              ],
            ],
          ),
          SizedBox(height: 5),
          bottomContent ?? SizedBox(),
        ],
      ),
    );
  }
}

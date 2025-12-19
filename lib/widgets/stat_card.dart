import 'package:flutter/material.dart';
import 'package:mosa/utils/app_colors.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.thirdBlue,
                  AppColors.sixthBlue,
                ],
                // transform: GradientRotation(0.785398),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng có',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '15.000.000 đ',
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.buttonPrimary,
              ),
              child: Icon(
                Icons.arrow_right_alt_sharp,
                color: AppColors.textWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

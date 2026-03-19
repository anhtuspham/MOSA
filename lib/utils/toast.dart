import 'package:flutter/material.dart';
import 'package:mosa/config/app_colors.dart';
import 'package:toastification/toastification.dart';

void showResultToast(String message, {bool isError = false}) {
  toastification.show(
    type: isError ? ToastificationType.error : ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: Text(isError ? 'Lỗi' : 'Thành công', style: TextStyle(fontWeight: FontWeight.w600)),
    description: Text(message, style: TextStyle(fontWeight: FontWeight.w600)),
    alignment: Alignment.topCenter,
    autoCloseDuration: Duration(seconds: 3),
  );
}

void showInfoToast(String message) {
  toastification.show(
    type: ToastificationType.info,
    style: ToastificationStyle.fillColored,
    description: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    ),
    alignment: Alignment.topCenter,
    autoCloseDuration: Duration(seconds: 2),
    foregroundColor: AppColors.textPrimary,
    icon: Icon(Icons.info_outline, color: AppColors.textPrimary),
    closeButton: ToastCloseButton(
      showType: CloseButtonShowType.always,
      buttonBuilder: (context, onClose) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.close,
              color: AppColors.textPrimary,
              size: 18,
            ),
          ),
        ),
      ),
    ),
  );
}


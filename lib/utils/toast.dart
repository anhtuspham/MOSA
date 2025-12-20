import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(String message, {bool isError = false}) {
  toastification.show(
    type: isError ? ToastificationType.error : ToastificationType.success,
    style: ToastificationStyle.fillColored,
    title: Text(
      isError ? 'Lỗi' : 'Thành công',
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    description: Text(
      message,
      style: TextStyle(fontWeight: FontWeight.w600),
    ),
    alignment: Alignment.topCenter,
    autoCloseDuration: Duration(seconds: 3),
  );
}
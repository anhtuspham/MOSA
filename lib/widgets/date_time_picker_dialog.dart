import 'package:flutter/material.dart';

Future<DateTime?> showDateTimePicker({required BuildContext context, DateTime? initialDate}) async {
  initialDate ??= DateTime.now();
  DateTime? pickedDate;
  TimeOfDay? time;

  pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(1990),
    lastDate: DateTime(2100),
  );

  if (pickedDate == null) return null;

  time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(pickedDate));

  if (time == null) return null;
  return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, time.hour, time.minute);
}

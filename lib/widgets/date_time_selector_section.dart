import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mosa/utils/date_time_extension.dart';
import 'package:mosa/utils/toast.dart';

import 'custom_list_tile.dart';
import 'date_time_picker_dialog.dart';

class DateTimeSelectorSection extends StatelessWidget {
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DateTimeSelectorSection({super.key, required this.selectedDateTime, required this.onDateTimeChanged});

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: Icon(Icons.calendar_month_outlined),
      title: Text('${selectedDateTime.weekdayLabel} - ${selectedDateTime.ddMMyyy}'),
      trailing: Text(selectedDateTime.hhMM),

      onTap: () async {
        final selected = await showDateTimePicker(context: context) ?? DateTime.now();
        onDateTimeChanged(selected);
      },
    );
  }
}

class DateOnlySelectorSection extends StatelessWidget {
  final DateTime? selectedDateOnly;
  final ValueChanged<DateTime?> onDateTimeChanged;
  final String defaultTitle;

  const DateOnlySelectorSection({super.key, this.selectedDateOnly, required this.onDateTimeChanged, required this.defaultTitle});

  bool _isDateBeforeToday() {
    if (selectedDateOnly == null) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final selectedDate = DateTime(selectedDateOnly!.year, selectedDateOnly!.month, selectedDateOnly!.day);
    return selectedDate.isBefore(todayDate);
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isDateBeforeToday();

    return CustomListTile(
      leading: Icon(Icons.calendar_month_outlined),
      title: Row(
        children: [
          Text(
            selectedDateOnly != null ? selectedDateOnly!.ddMMyyy : defaultTitle,
            style: TextStyle(
              color: isOverdue ? Colors.amberAccent.shade700 : null,
              fontWeight: isOverdue ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
      trailing: selectedDateOnly != null
          ? IconButton(
              onPressed: () => onDateTimeChanged(null),
              icon: Icon(Icons.highlight_remove_outlined),
            )
          : null,
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          firstDate: DateTime(1990),
          lastDate: DateTime(2100),
        );

        if (selected == null) return;

        // Check if the newly selected date is before today
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final selectedDate = DateTime(selected.year, selected.month, selected.day);

        if (selectedDate.isBefore(todayDate)) {
          showInfoToast('Ngày trả nợ phải lớn hơn hoặc bằng ngày ${today.day}/${today.month}/${today.year}.');
        }

        log('selectedDate: ${selected.ddMMyyy}');
        onDateTimeChanged(selected);
      },
    );
  }
}

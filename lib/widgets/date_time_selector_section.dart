import 'package:flutter/material.dart';
import 'package:mosa/utils/date_time_extension.dart';

import 'custom_list_tile.dart';
import 'date_time_picker_dialog.dart';

class DateTimeSelectorSection extends StatelessWidget {
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  const DateTimeSelectorSection({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      leading: Icon(Icons.calendar_month_outlined),
      title: Text(
        '${selectedDateTime.weekdayLabel} - ${selectedDateTime.ddMMyyy}',
      ),
      trailing: Text(selectedDateTime.hhMM),

      onTap: () async {
        final selected =
            await showDateTimePicker(context: context) ?? DateTime.now();
        onDateTimeChanged(selected);
      },
    );
  }
}

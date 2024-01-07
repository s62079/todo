import 'package:flutter/material.dart';

class DateTimePickerView extends StatefulWidget {
  final Function getPicked, setPicked;

  const DateTimePickerView(this.getPicked, this.setPicked, {super.key});

  @override
  State<StatefulWidget> createState() {
    return _DateTimePickerViewState();
  }
}

class _DateTimePickerViewState extends State<DateTimePickerView> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final DateTime? picked = widget.getPicked();
        final DateTime now = DateTime.now();

        DateTime? date = await showDatePicker(
          context: context,
          initialDate: picked ?? now,
          firstDate: now,
          lastDate: now.copyWith(year: now.year + 1),
        );
        if (date != null && context.mounted) {
          TimeOfDay now = (picked != null)
              ? TimeOfDay.fromDateTime(picked)
              : TimeOfDay.now();
          TimeOfDay? time =
              await showTimePicker(context: context, initialTime: now);
          if (time != null) {
            date = date.add(Duration(hours: time.hour, minutes: time.minute));
          }
        }
        setState(() => widget.setPicked(date));
      },
      icon: Icon(
        Icons.calendar_month,
        color: (widget.getPicked() != null) ? Colors.blue : null,
      ),
    );
  }
}

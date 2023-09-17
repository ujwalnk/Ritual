import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker(
      {super.key, this.restorationId, this.startDate, this.endDate, required this.onDateSelected});

  final String? restorationId;
  final DateTime? startDate;
  final DateTime? endDate;

  final void Function(DateTime) onDateSelected; // Callback function

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _CustomDatePickerState extends State<CustomDatePicker>
    with RestorationMixin {
  @override
  String? get restorationId => widget.restorationId;
  String selectedDate = "Open Date Picker";

  final RestorableDateTime _selectedDate = RestorableDateTime(DateTime.now());
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    final DateTime initialDate =
        DateTime.fromMillisecondsSinceEpoch(arguments! as int);
    final CustomDatePicker? widget =
        context.findAncestorWidgetOfExactType<CustomDatePicker>();
    final DateTime? startDate = widget?.startDate;
    final DateTime? endDate = widget?.endDate;

    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: initialDate,
          firstDate: startDate ?? DateTime.now(),
          lastDate:
              endDate ?? DateTime.now().add(const Duration(days: 365 * 10)),
        );
      },
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _selectedDate.value = newSelectedDate;
        final List<String> monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        selectedDate = "${monthNames[newSelectedDate.month]} ${newSelectedDate.day.toString()}, ${newSelectedDate.year.toString()}";
      });

      // Call the callback function with the selected date
      widget.onDateSelected(newSelectedDate);

    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        _restorableDatePickerRouteFuture.present();
      },
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text(
        selectedDate,
        style: const TextStyle(
          fontFamily: "NotoSans-Light",
        ),
      ),
    );
  }
}

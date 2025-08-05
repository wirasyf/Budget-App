import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerDialogs {
  static Future<void> show({
    required BuildContext context,
    required DateTime selectedDate,
    required String selectedDateMode,
    required Function(DateTime) onDateSelected,
  }) async {
    switch (selectedDateMode) {
      case 'Daily':
        await _pickDay(context, selectedDate, onDateSelected);
        break;
      case 'Monthly':
        await _pickMonth(context, selectedDate, onDateSelected);
        break;
      case 'Yearly':
        await _pickYear(context, selectedDate, onDateSelected);
        break;
    }
  }

  static Future<void> _pickDay(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) onDateSelected(picked);
  }

  static Future<void> _pickMonth(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) async {
    final now = DateTime.now();
    int pickedMonth = selectedDate.month;
    int pickedYear = selectedDate.year;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 250,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Pilih Bulan & Tahun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<int>(
                        value: pickedMonth,
                        items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(
                              DateFormat('MMMM').format(DateTime(0, index + 1)),
                            ),
                          );
                        }),
                        onChanged: (val) => setModalState(() => pickedMonth = val!),
                      ),
                      DropdownButton<int>(
                        value: pickedYear,
                        items: List.generate(now.year - 2019, (index) {
                          return DropdownMenuItem(
                            value: 2020 + index,
                            child: Text('${2020 + index}'),
                          );
                        }),
                        onChanged: (val) => setModalState(() => pickedYear = val!),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      onDateSelected(DateTime(pickedYear, pickedMonth));
                      Navigator.pop(context);
                    },
                    child: const Text('Pilih'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> _pickYear(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateSelected,
  ) async {
    final now = DateTime.now();
    int pickedYear = selectedDate.year;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SizedBox(
              height: 250,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Pilih Tahun',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  DropdownButton<int>(
                    value: pickedYear,
                    items: List.generate(now.year - 2019, (index) {
                      return DropdownMenuItem(
                        value: 2020 + index,
                        child: Text('${2020 + index}'),
                      );
                    }),
                    onChanged: (val) => setModalState(() => pickedYear = val!),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      onDateSelected(DateTime(pickedYear));
                      Navigator.pop(context);
                    },
                    child: const Text('Pilih'),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterHeader extends StatelessWidget with ThemeHelper {
  final DateTime selectedDate;
  final String selectedDateMode;
  final VoidCallback onDateTap;
  final VoidCallback onFilterTap;

  const FilterHeader({
    super.key,
    required this.selectedDate,
    required this.selectedDateMode,
    required this.onDateTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardBackgroundColor(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: onDateTap,
              icon: Icon(
                Icons.calendar_today,
                color: primaryTextColor(context),
              ),
              label: Text(
                _getFormattedDate(),
                style: TextStyle(
                  fontSize: 16,
                  color: primaryTextColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: onFilterTap,
              icon: Icon(
                Icons.filter_list,
                size: 30,
                color: primaryTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormattedDate() {
    switch (selectedDateMode) {
      case 'Daily':
        return DateFormat('d MMM yyyy').format(selectedDate);
      case 'Monthly':
        return DateFormat('MMMM yyyy').format(selectedDate);
      case 'Yearly':
        return DateFormat('yyyy').format(selectedDate);
      default:
        return DateFormat('MMMM yyyy').format(selectedDate);
    }
  }
}

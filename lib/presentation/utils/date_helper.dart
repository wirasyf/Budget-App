class DateHelper {
  static DateTime getStartDate(DateTime selectedDate, String dateMode) {
    switch (dateMode) {
      case 'Daily':
        return DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
      case 'Monthly':
        return DateTime(selectedDate.year, selectedDate.month);
      case 'Yearly':
        return DateTime(selectedDate.year);
      default:
        return DateTime(selectedDate.year, selectedDate.month);
    }
  }

  static DateTime getEndDate(DateTime selectedDate, String dateMode) {
    switch (dateMode) {
      case 'Daily':
        return getStartDate(
          selectedDate,
          dateMode,
        ).add(const Duration(days: 1));
      case 'Monthly':
        return DateTime(selectedDate.year, selectedDate.month + 1);
      case 'Yearly':
        return DateTime(selectedDate.year + 1);
      default:
        return DateTime(selectedDate.year, selectedDate.month + 1);
    }
  }
}

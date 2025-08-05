import 'package:cloud_firestore/cloud_firestore.dart';
import 'date_helper.dart';

class QueryBuilder {
  static Query buildQuery(
    String uid,
    DateTime selectedDate,
    String selectedDateMode,
    String selectedType,
    String selectedCategory,
  ) {
    final start = DateHelper.getStartDate(selectedDate, selectedDateMode);
    final end = DateHelper.getEndDate(selectedDate, selectedDateMode);

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true);

    if (selectedType != 'All') {
      query = query.where('type', isEqualTo: selectedType);
    }
    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return query;
  }
}

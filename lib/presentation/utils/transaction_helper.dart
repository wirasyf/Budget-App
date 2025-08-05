import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

mixin TransactionHelper {
  DateTime getStartDateByFilter(int selectedIndex) {
    final now = DateTime.now();
    switch (selectedIndex) {
      case 0:
        return DateTime(now.year, now.month, now.day);
      case 1:
        return now.subtract(Duration(days: now.weekday - 1));
      case 2:
        return DateTime(now.year, now.month);
      case 3:
        return DateTime(now.year);
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  Stream<Map<String, dynamic>> getTransactionSummary() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          double income = 0.0;
          double expense = 0.0;

          for (var doc in snapshot.docs) {
            final data = doc.data();
            final amountRaw = data['amount'] ?? 0;
            final amount = amountRaw is int ? amountRaw.toDouble() : amountRaw;
            final type = data['type']?.toString();

            if (type == 'Income') {
              income += amount;
            } else if (type == 'Expense') {
              expense += amount;
            }
          }

          return {
            'income': income,
            'expense': expense,
            'balance': income - expense,
          };
        });
  }

  Stream<QuerySnapshot> getTransactions(int selectedIndex) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final startDate = getStartDateByFilter(selectedIndex);

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }
}

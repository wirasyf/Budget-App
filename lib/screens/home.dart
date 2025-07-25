import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_app/const/color.dart';
import 'package:budget_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  DateTime getStartDateByFilter() {
    final now = DateTime.now();
    switch (selectedIndex) {
      case 0:
        return DateTime(now.year, now.month, now.day); // Today
      case 1:
        return now.subtract(Duration(days: now.weekday - 1)); // Start of week
      case 2:
        return DateTime(now.year, now.month); // Start of month
      case 3:
        return DateTime(now.year); // Start of year
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

  Stream<QuerySnapshot> getTransactions() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final startDate = getStartDateByFilter();

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      case 'investment':
        return Icons.trending_up;
      case 'health':
        return Icons.health_and_safety;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: isDark ? appPrimaryDark : appPrimary,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? appPrimaryDark : appPrimary,
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: appYellow,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.person, size: 20, color: appWhite),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        themeNotifier.toggleTheme();
                      },
                      icon: Icon(isDark ? Icons.sunny : Icons.dark_mode),
                      iconSize: 28,
                      color: appYellow,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Balance
                StreamBuilder<Map<String, dynamic>>(
                  stream: getTransactionSummary(),
                  builder: (context, snapshot) {
                    final balance = snapshot.data?['balance'] ?? 0.0;
                    return Column(
                      children: [
                        Text(
                          "Total Balance",
                          style: TextStyle(fontSize: 16, color: appBlackSoft, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Rp${balance.toStringAsFixed(0)}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? appBlack : appWhite,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 25),

                // Income and Expense
                StreamBuilder<Map<String, dynamic>>(
                  stream: getTransactionSummary(),
                  builder: (context, snapshot) {
                    final income = snapshot.data?['income'] ?? 0.0;
                    final expense = snapshot.data?['expense'] ?? 0.0;

                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appGreen,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  _buildIconBox(
                                    appGreen,
                                    Icons.arrow_downward_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildAmountText("Income", income, appWhite),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: appRed,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  _buildIconBox(
                                    appRed,
                                    Icons.arrow_upward_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildAmountText(
                                    "Expense",
                                    expense,
                                    appWhite,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Filter Buttons
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterButton("Today", 0),
                      _buildFilterButton("Week", 1),
                      _buildFilterButton("Month", 2),
                      _buildFilterButton("Year", 3),
                    ],
                  ),
                ),

                // Recent Transaction
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transaction",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? appBlack : appWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),

                // List Transactions
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No transactions", style: TextStyle(color: isDark ? appBlack : appWhite ),));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final isExpense = data['type'] == 'Expense';
                          final icon = getCategoryIcon(data['category'] ?? '');

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            child: Material(
                              color: isDark ? appPrimary : appPrimaryDark,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ListTile(
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        color: isExpense
                                            ? appRedSoft
                                            : appGreenSoft,
                                      ),
                                      child: Icon(
                                        icon,
                                        color: isExpense ? appRed : appGreen,
                                      ),
                                    ),
                                    title: Text(data['title'] ?? ''),
                                    subtitle: Text(data['category'] ?? ''),
                                    trailing: Text(
                                      "${isExpense ? '-' : '+'}Rp${data['amount']}",
                                      style: TextStyle(
                                        color: isExpense ? appRed : appGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountText(String label, double amount, Color textColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Rp${amount.toStringAsFixed(0)}",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconBox(Color borderColor, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: appWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: borderColor, size: 20),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: selectedIndex == index ? appYellowSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: selectedIndex == index ? appYellow : appBlackSoft,
            fontWeight: selectedIndex == index
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

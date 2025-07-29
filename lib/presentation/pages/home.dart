import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:budget_app/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late final Stream<Map<String, dynamic>> transactionSummaryStream;

  @override
  void initState() {
    super.initState();
    transactionSummaryStream = getTransactionSummary();
  }

  DateTime getStartDateByFilter() {
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

  // Helper methods untuk warna tema gelap
  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : Colors.white;
  }

  Color get cardBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF161B22) : appPrimary;
  }

  Color get primaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  Color get secondaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8B949E) : appBlackSoft;
  }

  Color get appBarBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : appPrimary;
  }

  Color get appBarTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor,
        elevation: 0,
        title: Text(
          "Homepage",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: appBarTextColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              themeNotifier.toggleTheme();
            },
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            color: appBarTextColor,
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                StreamBuilder<Map<String, dynamic>>(
                  stream: transactionSummaryStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? {};
                    final balance = (data['balance'] ?? 0.0) as double;
                    final income = (data['income'] ?? 0.0) as double;
                    final expense = (data['expense'] ?? 0.0) as double;

                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF30363D),
                                width: 1,
                              )
                            : null,
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Total Balance",
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Text(
                              "Rp${balance.toStringAsFixed(0)}",
                              key: ValueKey(balance),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  income,
                                  "Income",
                                  appGreen,
                                  Icons.arrow_downward_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  expense,
                                  "Expense",
                                  appRed,
                                  Icons.arrow_upward_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 18,
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? const Color(0xFF58A6FF) : appPrimary,
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No transactions yet",
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final isExpense = data['type'] == 'Expense';
                          final icon = getCategoryIcon(data['category'] ?? '');

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 4,
                            ),
                            child: Material(
                              color: cardBackgroundColor,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {},
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: isDark
                                        ? Border.all(
                                            color: const Color(0xFF30363D),
                                            width: 1,
                                          )
                                        : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            color: isExpense
                                                ? (isDark
                                                      ? appRed.withOpacity(0.2)
                                                      : appRedSoft)
                                                : (isDark
                                                      ? appGreen.withOpacity(
                                                          0.2,
                                                        )
                                                      : appGreenSoft),
                                          ),
                                          child: Icon(
                                            icon,
                                            color: isExpense
                                                ? appRed
                                                : appGreen,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data['title'] ?? '',
                                                style: TextStyle(
                                                  color: primaryTextColor,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                data['category'] ?? '',
                                                style: TextStyle(
                                                  color: secondaryTextColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          "${isExpense ? '-' : '+'}Rp${data['amount']}",
                                          style: TextStyle(
                                            color: isExpense
                                                ? appRed
                                                : appGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
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
              color: textColor.withOpacity(0.9),
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

  Widget _buildSummaryCard(
    double value,
    String label,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isDark ? 0.3 : 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIconBox(color, icon),
            const SizedBox(width: 12),
            _buildAmountText(label, value, appWhite),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBox(Color borderColor, IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: appWhite,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: borderColor, size: 20),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    final bool isSelected = selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? appYellow : const Color(0xFF58A6FF))
            : (isDark ? const Color(0xFF21262D) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        border: isDark && !isSelected
            ? Border.all(color: const Color(0xFF30363D), width: 1)
            : null,
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(70, 36),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? appWhite
                : (isDark ? secondaryTextColor : appBlackSoft),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

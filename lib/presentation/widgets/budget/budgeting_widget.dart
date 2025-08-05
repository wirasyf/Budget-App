import 'package:budget_app/presentation/theme/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BudgetingWidget extends StatelessWidget {
  final User? user;
  final String currentMonth;
  final NumberFormat formatRupiah;
  final Function(BuildContext, DocumentSnapshot) onEditBudget;

  const BudgetingWidget({
    super.key,
    required this.user,
    required this.currentMonth,
    required this.formatRupiah,
    required this.onEditBudget,
  });

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  Color cardColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF161B22) : Colors.white;
  Color primaryTextColor(BuildContext context) =>
      isDark(context) ? const Color(0xFFE6EDF3) : appBlack;
  Color secondaryTextColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF8B949E) : appBlackSoft;
  Color borderColor(BuildContext context) =>
      isDark(context) ? const Color(0xFF30363D) : Colors.grey.shade300;

  Widget _buildCategoryIcon(BuildContext context, String category) {
    final icons = {
      'Food': Icons.restaurant,
      'Transportation': Icons.directions_car,
      'Shopping': Icons.shopping_bag,
      'Bills': Icons.receipt,
      'Entertainment': Icons.movie,
      'Other': Icons.category,
    };
    return Container(
      decoration: BoxDecoration(
        color: isDark(context) ? const Color(0xFF21262D) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icons[category] ?? Icons.category,
        size: 20,
        color: appYellow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('budgets')
          .where('uid', isEqualTo: user?.uid)
          .where('month', isEqualTo: currentMonth)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: primaryTextColor(context)),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final budgets = snapshot.data!.docs;
        if (budgets.isEmpty) {
          return Center(
            child: Text(
              'Belum ada anggaran bulan ini.',
              style: TextStyle(color: secondaryTextColor(context)),
            ),
          );
        }

        return ListView.builder(
          itemCount: budgets.length,
          itemBuilder: (context, index) {
            final doc = budgets[index];
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'];
            final budgetAmount = (data['amount'] ?? 0).toDouble();
            final usedAmount = (data['used'] ?? 0).toDouble();
            final remaining = budgetAmount - usedAmount;
            final percent = (usedAmount / budgetAmount).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor(context), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildCategoryIcon(context, category),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Anggaran: ${formatRupiah.format(budgetAmount)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: secondaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          color: cardColor(context),
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEditBudget(context, doc);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: percent,
                      backgroundColor: isDark(context)
                          ? const Color(0xFF21262D)
                          : Colors.grey.shade300,
                      color: percent > 0.9
                          ? appRed
                          : (percent > 0.6 ? appYellow : appGreen),
                      minHeight: 10,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dipakai: ${formatRupiah.format(usedAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor(context),
                          ),
                        ),
                        Text(
                          'Sisa: ${formatRupiah.format(remaining)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: remaining < 0
                                ? appRed
                                : primaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

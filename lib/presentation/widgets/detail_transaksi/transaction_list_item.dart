import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:budget_app/presentation/utils/currency_formater.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget with ThemeHelper {
  final DocumentSnapshot doc;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;
  final Function(bool) onSelectionChanged;

  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Salary': Icons.attach_money,
    'Gift': Icons.card_giftcard,
    'Investment': Icons.trending_up,
    'Health': Icons.health_and_safety,
    'Other': Icons.category,
  };

  const TransactionListItem({
    super.key,
    required this.doc,
    required this.isSelecting,
    required this.isSelected,
    required this.onLongPress,
    required this.onTap,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final title = data['title'] ?? '-';
    final category = data['category'] ?? '-';
    final amountRaw = data['amount'] ?? 0;
    final amount = amountRaw is int
        ? amountRaw.toDouble()
        : amountRaw as double;
    final type = data['type'] ?? 'Expense';
    final isExpense = type == 'Expense';

    final timestamp = data['date'] as Timestamp?;
    String formattedDate = '';
    if (timestamp != null) {
      formattedDate = DateFormat('d MMM yy').format(timestamp.toDate());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onLongPress: onLongPress,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (isSelecting)
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) => onSelectionChanged(val ?? false),
                  ),
                Expanded(
                  child: ListTile(
                    leading: _buildCategoryIcon(context, category, isExpense),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        color: primaryTextColor(context),
                      ),
                    ),
                    subtitle: Text(
                      '$category • $formattedDate',
                      style: TextStyle(
                        color: secondaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                    trailing: Text(
                      isExpense
                          ? "- ${CurrencyFormatter.format(amount)}"
                          : "+ ${CurrencyFormatter.format(amount)}",
                      style: TextStyle(
                        color: isExpense ? appRed : appGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    String category,
    bool isExpense,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isExpense
            ? (isDark ? appRed.withOpacity(0.2) : appRedSoft)
            : (isDark ? appGreen.withOpacity(0.2) : appGreenSoft),
      ),
      child: Icon(
        categoryIcons[category] ?? Icons.category,
        color: isExpense ? appRed : appGreen,
      ),
    );
  }
}

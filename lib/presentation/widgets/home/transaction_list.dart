import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:budget_app/presentation/utils/category_icons.dart';
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
    final isExpense = data['type'] == 'Expense';
    final icon = CategoryIcons.getIcon(data['category'] ?? '');
    final date = (data['date'] as Timestamp?)?.toDate();
    final dateText = date != null ? DateFormat('d MMM yy').format(date) : '';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Material(
        color: cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onLongPress: onLongPress,
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(color: const Color(0xFF30363D), width: 1)
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (isSelecting)
                    Checkbox(
                      value: isSelected,
                      onChanged: (val) => onSelectionChanged(val ?? false),
                    ),
                  _buildCategoryIcon(context, icon, isExpense, isDark),
                  const SizedBox(width: 16),
                  _buildTransactionInfo(context, data, dateText),
                  _buildAmountText(data, isExpense),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    IconData icon,
    bool isExpense,
    bool isDark,
  ) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isExpense
            ? (isDark ? appRed.withOpacity(0.2) : appRedSoft)
            : (isDark ? appGreen.withOpacity(0.2) : appGreenSoft),
      ),
      child: Icon(icon, color: isExpense ? appRed : appGreen, size: 24),
    );
  }

  Widget _buildTransactionInfo(
    BuildContext context,
    Map<String, dynamic> data,
    String dateText,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['title'] ?? '',
            style: TextStyle(
              color: primaryTextColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data['category'] ?? ''} • $dateText',
            style: TextStyle(color: secondaryTextColor(context), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountText(Map<String, dynamic> data, bool isExpense) {
    return Text(
      "${isExpense ? '-' : '+'}${CurrencyFormatter.format(data['amount'])}",
      style: TextStyle(
        color: isExpense ? appRed : appGreen,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

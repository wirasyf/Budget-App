import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:budget_app/presentation/utils/currency_formater.dart';
import 'package:budget_app/presentation/widgets/home/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/presentation/theme/color.dart';


class BalanceCard extends StatelessWidget with ThemeHelper {
  final double balance;
  final double income;
  final double expense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBackgroundColor(context),
        borderRadius: BorderRadius.circular(20),
        border: isDark
            ? Border.all(color: const Color(0xFF30363D), width: 1)
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
              color: secondaryTextColor(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              CurrencyFormatter.format(balance),
              key: ValueKey(balance),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: primaryTextColor(context),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  value: income,
                  label: "Income",
                  color: appGreen,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  value: expense,
                  label: "Expense",
                  color: appRed,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

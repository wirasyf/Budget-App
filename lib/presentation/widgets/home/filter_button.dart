import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/presentation/theme/color.dart';

class FilterButtons extends StatelessWidget with ThemeHelper {
  final int selectedIndex;
  final Function(int) onFilterChanged;

  const FilterButtons({
    super.key,
    required this.selectedIndex,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildFilterButton(context, "Hari Ini", 0),
          _buildFilterButton(context, "Minggu", 1),
          _buildFilterButton(context, "Bulan", 2),
          _buildFilterButton(context, "Tahun", 3),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label, int index) {
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
        onPressed: () => onFilterChanged(index),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(70, 36),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? Colors.white
                : (isDark ? secondaryTextColor(context) : appBlackSoft),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

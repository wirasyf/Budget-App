import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class FilterDialog extends StatelessWidget with ThemeHelper {
  final String selectedDateMode;
  final String selectedType;
  final String selectedCategory;
  final Function(String, String, String) onApply;
  final VoidCallback onReset;

  static const List<String> categories = [
    'All',
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Salary',
    'Gift',
    'Investment',
    'Health',
    'Other',
  ];

  static const List<String> types = ['All', 'Expense', 'Income'];

  const FilterDialog({
    super.key,
    required this.selectedDateMode,
    required this.selectedType,
    required this.selectedCategory,
    required this.onApply,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    String tempDateMode = selectedDateMode;
    String tempType = selectedType;
    String tempCategory = selectedCategory;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter Transaksi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor(context),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tempDateMode,
                items: ['Daily', 'Monthly', 'Yearly'].map((mode) {
                  return DropdownMenuItem(value: mode, child: Text(mode));
                }).toList(),
                onChanged: (val) => setModalState(() => tempDateMode = val!),
                decoration: const InputDecoration(labelText: 'Mode Tanggal'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tempType,
                items: types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setModalState(() => tempType = val!),
                decoration: const InputDecoration(labelText: 'Tipe Transaksi'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tempCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setModalState(() => tempCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  onApply(tempDateMode, tempType, tempCategory);
                  Navigator.pop(context);
                },
                child: const Text('Terapkan Filter'),
              ),
              TextButton(
                onPressed: () {
                  onReset();
                  Navigator.pop(context);
                },
                child: const Text('Reset Filter'),
              ),
            ],
          ),
        );
      },
    );
  }

  static void show({
    required BuildContext context,
    required String selectedDateMode,
    required String selectedType,
    required String selectedCategory,
    required Function(String, String, String) onApply,
    required VoidCallback onReset,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterDialog(
        selectedDateMode: selectedDateMode,
        selectedType: selectedType,
        selectedCategory: selectedCategory,
        onApply: onApply,
        onReset: onReset,
      ),
    );
  } 
}

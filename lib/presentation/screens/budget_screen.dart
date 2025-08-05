import 'package:budget_app/presentation/widgets/budget/budgeting_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/color.dart';

class BudgetingScreen extends StatefulWidget {
  const BudgetingScreen({super.key});

  @override
  State<BudgetingScreen> createState() => _BudgetingScreenState();
}

class _BudgetingScreenState extends State<BudgetingScreen> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime selectedMonth = DateTime.now();

  final formatRupiah = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get backgroundColor => isDark ? const Color(0xFF0D1117) : Colors.white;
  Color get primaryTextColor => isDark ? const Color(0xFFE6EDF3) : appBlack;

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Bulan',
    );
    if (picked != null) {
      setState(() => selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final amountController = TextEditingController();
    String selectedCategory = 'Food';

    await showDialog(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text(
            'Tambah Budget',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: _buildBudgetForm(amountController, (val) {
            selectedCategory = val!;
          }, selectedCategory),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: primaryTextColor)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text);
                if (amount == null) return;

                final month = DateFormat('yyyy-MM').format(selectedMonth);
                final existing = await FirebaseFirestore.instance
                    .collection('budgets')
                    .where('uid', isEqualTo: user?.uid)
                    .where('category', isEqualTo: selectedCategory)
                    .where('month', isEqualTo: month)
                    .get();

                if (existing.docs.isNotEmpty) {
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kategori sudah ada di bulan ini!'),
                    ),
                  );
                  return;
                }

                await FirebaseFirestore.instance.collection('budgets').add({
                  'uid': user?.uid,
                  'category': selectedCategory,
                  'amount': amount,
                  'used': 0.0,
                  'month': month,
                });
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: appPrimary),
              child: Text('Simpan', style: TextStyle(color: appBlack)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditBudgetDialog(
    BuildContext context,
    DocumentSnapshot doc,
  ) async {
    final data = doc.data() as Map<String, dynamic>;
    final amountController = TextEditingController(
      text: data['amount'].toString(),
    );
    String selectedCategory = data['category'];

    await showDialog(
      context: context,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
          title: const Text(
            'Edit Budget',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: _buildBudgetForm(amountController, (val) {
            selectedCategory = val!;
          }, selectedCategory),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: primaryTextColor)),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(amountController.text);
                if (newAmount == null) return;
                doc.reference.update({
                  'category': selectedCategory,
                  'amount': newAmount,
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: appPrimary),
              child: Text('Simpan', style: TextStyle(color: appBlack)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetForm(
    TextEditingController controller,
    Function(String?) onChanged,
    String selectedCategory,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedCategory,
            items:
                [
                      'Food',
                      'Transportation',
                      'Shopping',
                      'Bills',
                      'Entertainment',
                      'Other',
                    ]
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
            onChanged: onChanged,
            dropdownColor: isDark ? const Color(0xFF21262D) : null,
            style: TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
              labelText: 'Kategori',
              labelStyle: TextStyle(color: primaryTextColor),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: primaryTextColor),
            decoration: InputDecoration(
              labelText: 'Jumlah Budget (Rp)',
              labelStyle: TextStyle(color: primaryTextColor),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('yyyy-MM').format(selectedMonth);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Budgeting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: primaryTextColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: isDark ? const Color(0xFF58A6FF) : appPrimary,
            ),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        backgroundColor: appYellow,
        child: Icon(Icons.add, color: isDark ? appBlack : appWhite),
      ),
      body: BudgetingWidget(
        user: user,
        currentMonth: currentMonth,
        formatRupiah: formatRupiah,
        onEditBudget: _showEditBudgetDialog,
      ),
    );
  }
}

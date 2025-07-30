import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/color.dart';

class BudgetingPage extends StatefulWidget {
  const BudgetingPage({super.key});

  @override
  State<BudgetingPage> createState() => _BudgetingPageState();
}

class _BudgetingPageState extends State<BudgetingPage> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime selectedMonth = DateTime.now();

  final formatRupiah = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMonth = DateFormat('yyyy-MM').format(selectedMonth);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Budgeting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        backgroundColor: appYellow,
        child: Icon(Icons.add, color: isDark ? appBlack : appWhite),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('budgets')
            .where('uid', isEqualTo: user?.uid)
            .where('month', isEqualTo: currentMonth)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final budgets = snapshot.data!.docs;

          if (budgets.isEmpty) {
            return Center(
              child: Text(
                'Belum ada anggaran bulan ini.',
                style: TextStyle(color: colorScheme.onBackground),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black26 : Colors.grey.shade300,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildCategoryIcon(category),
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
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Anggaran: ${formatRupiah.format(budgetAmount)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            color: colorScheme.surface,
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditBudgetDialog(context, doc);
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
                        backgroundColor: Colors.grey[300],
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
                              color: isDark ? Colors.grey[300] : Colors.black87,
                            ),
                          ),
                          Text(
                            'Sisa: ${formatRupiah.format(remaining)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: remaining < 0
                                  ? appRed
                                  : colorScheme.onSurface,
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
      ),
    );
  }

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
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
              child: const Text('Batal'),
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
              child: const Text('Simpan'),
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
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
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
              child: const Text('Batal'),
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
              child: const Text('Simpan'),
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
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah Budget (Rp)',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
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
        color: Theme.of(context).colorScheme.surfaceVariant,
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
}

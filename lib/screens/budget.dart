import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../const/color.dart';

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
    final currentMonth = DateFormat('yyyy-MM').format(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Budgeting',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
        backgroundColor: appPrimary,
        child: Icon(Icons.add, color: appWhite),
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
            return const Center(child: Text('Belum ada anggaran bulan ini.'));
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

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildCategoryIcon(category),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Anggaran: ${formatRupiah.format(budgetAmount)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditBudgetDialog(context, doc);
                              } else if (value == 'delete') {
                                doc.reference.delete();
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
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
                            : (percent > 0.6 ? appYellow : appPrimary),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dipakai: ${formatRupiah.format(usedAmount)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Sisa: ${formatRupiah.format(remaining)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: remaining < 0 ? appRed : Colors.black,
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
    final _amountController = TextEditingController();
    String selectedCategory = 'Food';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Tambah Budget',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
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
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => selectedCategory = val!,
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
                  controller: _amountController,
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount == null) return;

                final month = DateFormat('yyyy-MM').format(selectedMonth);
                final existing = await FirebaseFirestore.instance
                    .collection('budgets')
                    .where('uid', isEqualTo: user?.uid)
                    .where('category', isEqualTo: selectedCategory)
                    .where('month', isEqualTo: month)
                    .get();

                if (existing.docs.isNotEmpty) {
                  Navigator.pop(context);
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
    final _amountController = TextEditingController(
      text: data['amount'].toString(),
    );
    String selectedCategory = data['category'];

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Edit Budget',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
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
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => selectedCategory = val!,
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
                  controller: _amountController,
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = double.tryParse(_amountController.text);
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
        color: appWhiteDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          icons[category] ?? Icons.category,
          size: 20,
          color: appYellow,
        ),
      ),
    );
  }
}

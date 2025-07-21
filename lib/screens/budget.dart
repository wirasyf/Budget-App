// budgeting_page.dart
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

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('yyyy-MM').format(selectedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgeting'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
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
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildCategoryIcon(category),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'Rp ${budgetAmount.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey[300],
                        color: percent > 0.9
                            ? Colors.red
                            : (percent > 0.6 ? Colors.orange : Colors.green),
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Digunakan: Rp ${usedAmount.toInt()}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            'Sisa: Rp ${remaining.toInt()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: remaining < 0 ? Colors.red : appBlack,
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
      setState(() {
        selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _showAddBudgetDialog(BuildContext context) async {
    final _amountController = TextEditingController();
    String selectedCategory = 'Food';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Tambah Budget'),
          content: Column(
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
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Budget (Rp)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(_amountController.text);
                if (amount != null) {
                  final month = DateFormat('yyyy-MM').format(selectedMonth);
                  FirebaseFirestore.instance.collection('budgets').add({
                    'uid': user?.uid,
                    'category': selectedCategory,
                    'amount': amount,
                    'used': 0,
                    'month': month,
                  });
                  Navigator.pop(context);
                }
              },
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
          title: const Text('Edit Budget'),
          content: Column(
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
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Budget (Rp)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = int.tryParse(_amountController.text);
                if (newAmount != null) {
                  doc.reference.update({
                    'category': selectedCategory,
                    'amount': newAmount,
                  });
                  Navigator.pop(context);
                }
              },
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
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[200],
      child: Icon(
        icons[category] ?? Icons.category,
        size: 20,
        color: Colors.black,
      ),
    );
  }
}

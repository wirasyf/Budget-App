import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  DateTime selectedMonth = DateTime.now();
  String selectedCategory = 'All';
  String selectedType = 'All';

  final List<String> categories = [
    'All',
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other',
  ];

  final List<String> types = ['All', 'Expense', 'Income'];

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filter Transaksi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: types.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (val) => setState(() => selectedType = val!),
                decoration: const InputDecoration(labelText: 'Tipe Transaksi'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) => setState(() => selectedCategory = val!),
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                child: const Text('Terapkan Filter'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedType = 'All';
                    selectedCategory = 'All';
                    selectedMonth = DateTime.now();
                  });
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

  Future<void> _pickMonth(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final start = DateTime(selectedMonth.year, selectedMonth.month);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1);

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: user?.uid)
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true);

    if (selectedType != 'All') {
      query = query.where('type', isEqualTo: selectedType);
    }
    if (selectedCategory != 'All') {
      query = query.where('category', isEqualTo: selectedCategory);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: Column(
        children: [
          // HEADER: Bulan dan Filter Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 30,
                          color: appBlack,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickMonth(context),
                        child: Text(
                          "${selectedMonth.month.toString().padLeft(2, '0')}/${selectedMonth.year}",
                          style: TextStyle(
                            fontSize: 18,
                            color: appBlack,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _openFilterDialog,
                  icon: Icon(Icons.filter_list, size: 30, color: appBlack),
                ),
              ],
            ),
          ),

          // Daftar Transaksi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(child: Text('Tidak ada transaksi.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? '-';
                    final category = data['category'] ?? '-';
                    final amount = data['amount']?.toString() ?? '0';
                    final type = data['type'] ?? 'Expense';
                    final isExpense = type == 'Expense';

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Material(
                        color: appBlue,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: isExpense ? appRedSoft : appGreenSoft,
                                ),
                                child: Icon(
                                  isExpense
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  color: isExpense ? appRed : appGreen,
                                ),
                              ),
                              title: Text(
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: appBlack,
                                ),
                              ),
                              subtitle: Text(
                                category,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Text(
                                isExpense ? "- Rp $amount" : "+ Rp $amount",
                                style: TextStyle(
                                  color: isExpense ? appRed : appGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

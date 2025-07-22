import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/const/color.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  DateTime selectedDate = DateTime.now();
  String selectedCategory = 'All';
  String selectedType = 'All';
  String selectedDateMode = 'Monthly';

  final List<String> categories = [
    'All',
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other',
  ];

  final Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Other': Icons.category,
  };

  final List<String> types = ['All', 'Expense', 'Income'];

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String tempType = selectedType;
        String tempCategory = selectedCategory;

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
                value: tempType,
                items: types
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (val) => tempType = val!,
                decoration: const InputDecoration(labelText: 'Tipe Transaksi'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: tempCategory,
                items: categories
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => tempCategory = val!,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedType = tempType;
                    selectedCategory = tempCategory;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Terapkan Filter'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedType = 'All';
                    selectedCategory = 'All';
                    selectedDate = DateTime.now();
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

  Future<void> _pickDate(BuildContext context) async {
    if (selectedDateMode == 'Daily') {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
      );
      if (picked != null) setState(() => selectedDate = picked);
    } else if (selectedDateMode == 'Monthly') {
      await _pickMonth(context);
    } else {
      await _pickYear(context);
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    int pickedMonth = selectedDate.month;
    int pickedYear = selectedDate.year;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Pilih Bulan & Tahun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<int>(
                    value: pickedMonth,
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'.padLeft(2, '0')),
                      );
                    }),
                    onChanged: (val) => pickedMonth = val!,
                  ),
                  DropdownButton<int>(
                    value: pickedYear,
                    items: List.generate(now.year - 2019, (index) {
                      return DropdownMenuItem(
                        value: 2020 + index,
                        child: Text('${2020 + index}'),
                      );
                    }),
                    onChanged: (val) => pickedYear = val!,
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(
                    () => selectedDate = DateTime(pickedYear, pickedMonth),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Pilih'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickYear(BuildContext context) async {
    final now = DateTime.now();
    int pickedYear = selectedDate.year;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text(
                'Pilih Tahun',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              DropdownButton<int>(
                value: pickedYear,
                items: List.generate(now.year - 2019, (index) {
                  return DropdownMenuItem(
                    value: 2020 + index,
                    child: Text('${2020 + index}'),
                  );
                }),
                onChanged: (val) => pickedYear = val!,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  setState(() => selectedDate = DateTime(pickedYear));
                  Navigator.pop(context);
                },
                child: const Text('Pilih'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _showEditTransactionDialog(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;

    TextEditingController titleController = TextEditingController(
      text: data['title'],
    );
    TextEditingController amountController = TextEditingController(
      text: data['amount'].toString(),
    );

    String selectedEditCategory = data['category'];
    String selectedEditType = data['type'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nominal'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedEditType,
                  items: types.where((e) => e != 'All').map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) => selectedEditType = val!,
                  decoration: const InputDecoration(labelText: 'Tipe'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedEditCategory,
                  items: categories.where((e) => e != 'All').map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => selectedEditCategory = val!,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appRed,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('transactions')
                              .doc(id)
                              .delete();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Hapus'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appGreen,
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('transactions')
                              .doc(id)
                              .update({
                                'title': titleController.text,
                                'amount':
                                    int.tryParse(amountController.text) ?? 0,
                                'type': selectedEditType,
                                'category': selectedEditCategory,
                              });
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    late DateTime start;
    late DateTime end;

    if (selectedDateMode == 'Daily') {
      start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      end = start.add(const Duration(days: 1));
    } else if (selectedDateMode == 'Monthly') {
      start = DateTime(selectedDate.year, selectedDate.month);
      end = DateTime(selectedDate.year, selectedDate.month + 1);
    } else {
      start = DateTime(selectedDate.year);
      end = DateTime(selectedDate.year + 1);
    }

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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: appBlue,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedDateMode,
                      items: ['Daily', 'Monthly', 'Yearly']
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedDateMode = val!),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _pickDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(
                          selectedDateMode == 'Daily'
                              ? "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
                              : selectedDateMode == 'Monthly'
                              ? "${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
                              : "${selectedDate.year}",
                          style: TextStyle(
                            fontSize: 16,
                            color: appBlack,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openFilterDialog,
                      icon: Icon(Icons.filter_list, size: 30, color: appBlack),
                    ),
                  ],
                ),
              ),
            ),
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
                            onTap: () =>
                                _showEditTransactionDialog(docs[index]),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isExpense
                                        ? appRedSoft
                                        : appGreenSoft,
                                  ),
                                  child: Icon(
                                    categoryIcons[category] ?? Icons.category,
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
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  isExpense ? "- Rp $amount" : "+ Rp $amount",
                                  style: TextStyle(
                                    color: isExpense ? appRed : appGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
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
      ),
    );
  }
}

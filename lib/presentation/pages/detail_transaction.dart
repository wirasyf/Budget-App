import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:intl/intl.dart';

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

  bool isSelecting = false;
  Set<String> selectedIds = {};

  final List<String> categories = [
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

  final Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Salary': Icons.attach_money,
    'Gift': Icons.card_giftcard,
    'Investment': Icons.trending_up,
    'Health': Icons.health_and_safety,
    'Other': Icons.category,
  };

  final List<String> types = ['All', 'Expense', 'Income'];

  Color get backgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : appPrimary;
  }

  Color get cardBackgroundColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF161B22) : appPrimaryDark;
  }

  Color get primaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  Color get secondaryTextColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8B949E) : appBlackSoft;
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedDateMode,
                    items: ['Daily', 'Monthly', 'Yearly'].map((mode) {
                      return DropdownMenuItem(value: mode, child: Text(mode));
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedDateMode = val!),
                    decoration: const InputDecoration(
                      labelText: 'Mode Tanggal',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: types.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedType = val!),
                    decoration: const InputDecoration(
                      labelText: 'Tipe Transaksi',
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedCategory = val!),
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
                        selectedDate = DateTime.now();
                        selectedDateMode = 'Monthly';
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                            child: Text(
                              DateFormat('MMMM').format(DateTime(0, index + 1)),
                            ),
                          );
                        }),
                        onChanged: (val) =>
                            setModalState(() => pickedMonth = val!),
                      ),
                      DropdownButton<int>(
                        value: pickedYear,
                        items: List.generate(now.year - 2019, (index) {
                          return DropdownMenuItem(
                            value: 2020 + index,
                            child: Text('${2020 + index}'),
                          );
                        }),
                        onChanged: (val) =>
                            setModalState(() => pickedYear = val!),
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    onChanged: (val) => setModalState(() => pickedYear = val!),
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
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    Text(
                      'Edit Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
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
                      onChanged: (val) =>
                          setModalState(() => selectedEditType = val!),
                      decoration: const InputDecoration(labelText: 'Tipe'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedEditCategory,
                      items: categories.where((e) => e != 'All').map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (val) =>
                          setModalState(() => selectedEditCategory = val!),
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
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.delete, color: appWhite),
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
                                        int.tryParse(amountController.text) ??
                                        0,
                                    'type': selectedEditType,
                                    'category': selectedEditCategory,
                                  });
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.save, color: appWhite),
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
      backgroundColor: backgroundColor,
      floatingActionButton: isSelecting
          ? FloatingActionButton.extended(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Hapus Transaksi'),
                    content: Text(
                      'Yakin ingin menghapus ${selectedIds.length} transaksi?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final batch = FirebaseFirestore.instance.batch();
                  for (final id in selectedIds) {
                    batch.delete(
                      FirebaseFirestore.instance
                          .collection('transactions')
                          .doc(id),
                    );
                  }
                  await batch.commit();
                  setState(() {
                    isSelecting = false;
                    selectedIds.clear();
                  });
                }
              },
              backgroundColor: appRed,
              icon: const Icon(Icons.delete),
              label: Text('Hapus (${selectedIds.length})'),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: cardBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => _pickDate(context),
                      icon: Icon(Icons.calendar_today, color: primaryTextColor),
                      label: Text(
                        selectedDateMode == 'Daily'
                            ? DateFormat('d MMM yyyy').format(selectedDate)
                            : selectedDateMode == 'Monthly'
                            ? DateFormat('MMMM yyyy').format(selectedDate)
                            : DateFormat('yyyy').format(selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openFilterDialog,
                      icon: Icon(
                        Icons.filter_list,
                        size: 30,
                        color: primaryTextColor,
                      ),
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
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: primaryTextColor),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Tidak ada transaksi.',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final id = docs[index].id;
                      final title = data['title'] ?? '-';
                      final category = data['category'] ?? '-';
                      final amount = data['amount']?.toString() ?? '0';
                      final type = data['type'] ?? 'Expense';
                      final isExpense = type == 'Expense';

                      final timestamp = data['date'] as Timestamp?;
                      String formattedDate = '';
                      if (timestamp != null) {
                        formattedDate = DateFormat(
                          'd MMM yy',
                        ).format(timestamp.toDate());
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Material(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onLongPress: () {
                              setState(() {
                                isSelecting = true;
                                selectedIds.add(id);
                              });
                            },
                            onTap: () {
                              if (isSelecting) {
                                setState(() {
                                  if (selectedIds.contains(id)) {
                                    selectedIds.remove(id);
                                  } else {
                                    selectedIds.add(id);
                                  }
                                  if (selectedIds.isEmpty) {
                                    isSelecting = false;
                                  }
                                });
                              } else {
                                _showEditTransactionDialog(docs[index]);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  if (isSelecting)
                                    Checkbox(
                                      value: selectedIds.contains(id),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            selectedIds.add(id);
                                          } else {
                                            selectedIds.remove(id);
                                          }
                                          if (selectedIds.isEmpty) {
                                            isSelecting = false;
                                          }
                                        });
                                      },
                                    ),
                                  Expanded(
                                    child: ListTile(
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          color: isExpense
                                              ? (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? appRed.withOpacity(0.2)
                                                    : appRedSoft)
                                              : (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? appGreen.withOpacity(0.2)
                                                    : appGreenSoft),
                                        ),
                                        child: Icon(
                                          categoryIcons[category] ??
                                              Icons.category,
                                          color: isExpense ? appRed : appGreen,
                                        ),
                                      ),
                                      title: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: primaryTextColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '$category • $formattedDate',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 13,
                                        ),
                                      ),
                                      trailing: Text(
                                        isExpense
                                            ? "- Rp $amount"
                                            : "+ Rp $amount",
                                        style: TextStyle(
                                          color: isExpense ? appRed : appGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

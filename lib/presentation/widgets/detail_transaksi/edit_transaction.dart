import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/presentation/theme/color.dart';


class EditTransactionDialog extends StatelessWidget with ThemeHelper {
  final DocumentSnapshot doc;

  static const List<String> categories = [
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

  static const List<String> types = ['Expense', 'Income'];

  const EditTransactionDialog({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
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
                    color: primaryTextColor(context),
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
                  items: types.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (val) =>
                      setModalState(() => selectedEditType = val!),
                  decoration: const InputDecoration(labelText: 'Tipe'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedEditCategory,
                  items: categories.map((cat) {
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
                          if (context.mounted) Navigator.pop(context);
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
                                    int.tryParse(amountController.text) ?? 0,
                                'type': selectedEditType,
                                'category': selectedEditCategory,
                              });
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: Icon(Icons.save, color: appWhite),
                        label: Text(
                          'Simpan',
                          style: TextStyle(color: appWhite),
                        ),
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

  static void show(BuildContext context, DocumentSnapshot doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditTransactionDialog(doc: doc),
    );
  }
}

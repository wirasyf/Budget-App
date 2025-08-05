import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/presentation/theme/color.dart';

void showEditTransactionDialog(BuildContext context, DocumentSnapshot doc) {
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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFFE6EDF3)
                          : appBlack,
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
                    items: ['Income', 'Expense']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedEditType = val!),
                    decoration: const InputDecoration(labelText: 'Tipe'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedEditCategory,
                    items:
                        [
                              'Food',
                              'Transportation',
                              'Shopping',
                              'Bills',
                              'Entertainment',
                              'Salary',
                              'Gift',
                              'Investment',
                              'Health',
                              'Other',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
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
                          icon: const Icon(Icons.delete, color: Colors.white),
                          label: Text(
                            'Hapus',
                            style: TextStyle(color: appWhite),
                          ),
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
                          icon: const Icon(Icons.save, color: Colors.white),
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
    },
  );
}

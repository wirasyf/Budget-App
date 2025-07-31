import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/color.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Expense';
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _types = ['Expense', 'Income'];
  final List<String> _categories = [
    'Food',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills',
    'Other',
  ];

  final Map<String, IconData> _categoryIcons = {
    'Food': Icons.fastfood,
    'Transportation': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Other': Icons.category,
  };

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
  Color get themeColor => isDark ? appYellow : Colors.blue;

  Color get backgroundColor => isDark ? const Color(0xFF0D1117) : Colors.white;

  Color get cardColor =>
      isDark ? const Color(0xFF161B22) : Colors.grey.shade100;

  Color get primaryTextColor => isDark ? const Color(0xFFE6EDF3) : appBlack;

  Color get secondaryTextColor =>
      isDark ? const Color(0xFF8B949E) : appBlackSoft;

  Color get borderColor =>
      isDark ? const Color(0xFF30363D) : Colors.grey.shade300;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text.trim());
      final month = DateFormat('yyyy-MM').format(_selectedDate);

      await FirebaseFirestore.instance.collection('transactions').add({
        'uid': user.uid,
        'title': _titleController.text.trim(),
        'amount': amount,
        'type': _selectedType,
        'category': _selectedCategory,
        'date': Timestamp.fromDate(_selectedDate),
        'month': month,
        'description': _descriptionController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      await _updateBudget(
        uid: user.uid,
        category: _selectedCategory,
        type: _selectedType,
        amount: amount,
        month: month,
      );

      _formKey.currentState!.reset();
      _titleController.clear();
      _amountController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedType = 'Expense';
        _selectedCategory = 'Food';
        _selectedDate = DateTime.now();
      });

      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Transaction saved successfully'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateBudget({
    required String uid,
    required String category,
    required String type,
    required double amount,
    required String month,
  }) async {
    if (type != 'Expense') return;

    final snapshot = await FirebaseFirestore.instance
        .collection('budgets')
        .where('uid', isEqualTo: uid)
        .where('category', isEqualTo: category)
        .where('month', isEqualTo: month)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return;

    final doc = snapshot.docs.first;
    final used = (doc['used'] ?? 0).toDouble();

    await doc.reference.update({'used': used + amount});
  }

  InputDecoration _fancyInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: primaryTextColor),
      filled: true,
      fillColor: cardColor,
      prefixIcon: Icon(icon, color: themeColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide(color: themeColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
    );
  }

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? themeColor.withOpacity(0.2) : cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? themeColor : borderColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_categoryIcons[cat], size: 20, color: themeColor),
                const SizedBox(width: 6),
                Text(cat, style: TextStyle(color: primaryTextColor)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'New Transaction',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
        ),
        iconTheme: IconThemeData(color: primaryTextColor),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(15),
                  color: cardColor,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: _fancyInput('Title', Icons.title),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Enter title'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: _fancyInput('Amount', Icons.attach_money),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Enter valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          items: _types
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              )
                              .toList(),
                          decoration: _fancyInput('Type', Icons.swap_horiz),
                          onChanged: (val) =>
                              setState(() => _selectedType = val!),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(15),
                          child: InputDecorator(
                            decoration: _fancyInput(
                              'Date',
                              Icons.calendar_today,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryTextColor,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          decoration: _fancyInput('Description', Icons.notes),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCategorySelector(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: const Text('Simpan Transaksi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                      elevation: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

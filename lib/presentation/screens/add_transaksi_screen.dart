import 'dart:async';
import 'package:budget_app/presentation/widgets/add_transaksi/add_transaction_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/color.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
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
  Color get primaryTextColor => isDark ? const Color(0xFFE6EDF3) : appBlack;

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
      body: TransactionFormWidget(
        formKey: _formKey,
        titleController: _titleController,
        amountController: _amountController,
        descriptionController: _descriptionController,
        selectedType: _selectedType,
        selectedCategory: _selectedCategory,
        selectedDate: _selectedDate,
        types: _types,
        categories: _categories,
        categoryIcons: _categoryIcons,
        onTypeChanged: (type) => setState(() => _selectedType = type),
        onCategoryChanged: (category) =>
            setState(() => _selectedCategory = category),
        onDatePick: _pickDate,
        onSave: _saveTransaction,
      ),
    );
  }
}


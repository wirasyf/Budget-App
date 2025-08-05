import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:budget_app/presentation/utils/transaction_helper.dart';
import 'package:budget_app/presentation/widgets/home/balance_cart.dart';
import 'package:budget_app/presentation/widgets/home/filter_button.dart';
import 'package:budget_app/presentation/widgets/home/transaction_dialog.dart';
import 'package:budget_app/presentation/widgets/home/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:budget_app/main.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with ThemeHelper, TransactionHelper {
  int selectedIndex = 0;
  late final Stream<Map<String, dynamic>> transactionSummaryStream;
  bool isSelecting = false;
  Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    transactionSummaryStream = getTransactionSummary();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBackgroundColor(context),
        elevation: 0,
        title: Text(
          "Beranda",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: appBarTextColor(context),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => themeNotifier.toggleTheme(),
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            color: appBarTextColor(context),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: SafeArea(
        child: Container(
          color: backgroundColor(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildBalanceSection(),
                const SizedBox(height: 20),
                _buildFilterSection(),
                const SizedBox(height: 10),
                _buildTransactionHeader(),
                _buildTransactionList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!isSelecting) return null;

    return FloatingActionButton.extended(
      backgroundColor: appRed,
      icon: const Icon(Icons.delete),
      label: Text('Hapus (${selectedIds.length})'),
      onPressed: () => _handleBulkDelete(),
    );
  }

  Widget _buildBalanceSection() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: transactionSummaryStream,
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final balance = (data['balance'] ?? 0.0) as double;
        final income = (data['income'] ?? 0.0) as double;
        final expense = (data['expense'] ?? 0.0) as double;

        return BalanceCard(balance: balance, income: income, expense: expense);
      },
    );
  }

  Widget _buildFilterSection() {
    return FilterButtons(
      selectedIndex: selectedIndex,
      onFilterChanged: (index) => setState(() => selectedIndex = index),
    );
  }

  Widget _buildTransactionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Transactions",
            style: TextStyle(
              fontSize: 18,
              color: primaryTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: getTransactions(selectedIndex),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return TransactionListItem(
                doc: doc,
                isSelecting: isSelecting,
                isSelected: selectedIds.contains(doc.id),
                onLongPress: () => _handleItemLongPress(doc.id),
                onTap: () => _handleItemTap(doc),
                onSelectionChanged: (selected) =>
                    _handleSelectionChanged(doc.id, selected),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          isDark ? const Color(0xFF58A6FF) : appPrimary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: secondaryTextColor(context),
          ),
          const SizedBox(height: 16),
          Text(
            "Tidak ada transaksi.",
            style: TextStyle(color: secondaryTextColor(context), fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleItemLongPress(String docId) {
    setState(() {
      isSelecting = true;
      selectedIds.add(docId);
    });
  }

  void _handleItemTap(DocumentSnapshot doc) {
    if (isSelecting) {
      _handleSelectionChanged(doc.id, !selectedIds.contains(doc.id));
    } else {
      showEditTransactionDialog(context, doc);
    }
  }

  void _handleSelectionChanged(String docId, bool selected) {
    setState(() {
      if (selected) {
        selectedIds.add(docId);
      } else {
        selectedIds.remove(docId);
      }
      if (selectedIds.isEmpty) {
        isSelecting = false;
      }
    });
  }

  Future<void> _handleBulkDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Yakin ingin menghapus ${selectedIds.length} transaksi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: appRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in selectedIds) {
        batch.delete(
          FirebaseFirestore.instance.collection('transactions').doc(id),
        );
      }
      await batch.commit();
      setState(() {
        isSelecting = false;
        selectedIds.clear();
      });
    }
  }
}

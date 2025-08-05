import 'package:budget_app/presentation/controller/detail_controller.dart';
import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:budget_app/presentation/utils/query_builder.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/bulk_delete.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/confirm_dialog.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/date_picker_dialogs.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/edit_transaction.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/filter_dialog.dart';
import 'package:budget_app/presentation/widgets/detail_transaksi/filter_header.dart';
import 'package:budget_app/presentation/widgets/home/transaction_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction>
    with ThemeHelper {
  late final DetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DetailController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final query = QueryBuilder.buildQuery(
      user?.uid ?? '',
      _controller.selectedDate,
      _controller.selectedDateMode,
      _controller.selectedType,
      _controller.selectedCategory,
    );

    return Scaffold(
      backgroundColor: backgroundColor(context),
      floatingActionButton: _controller.isSelecting
          ? BulkDeleteFab(
              selectedCount: _controller.selectedIds.length,
              onPressed: () => _handleBulkDelete(),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            FilterHeader(
              selectedDate: _controller.selectedDate,
              selectedDateMode: _controller.selectedDateMode,
              onDateTap: () => _handleDatePick(),
              onFilterTap: () => _handleFilterDialog(),
            ),
            Expanded(child: _buildTransactionList(query)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(Query query) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: primaryTextColor(context)),
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
              style: TextStyle(color: secondaryTextColor(context)),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            return TransactionListItem(
              doc: docs[index],
              isSelecting: _controller.isSelecting,
              isSelected: _controller.selectedIds.contains(docs[index].id),
              onLongPress: () => _controller.startSelection(docs[index].id),
              onTap: () => _handleItemTap(docs[index]),
              onSelectionChanged: (selected) =>
                  _handleSelectionChanged(docs[index].id, selected),
            );
          },
        );
      },
    );
  }

  void _handleDatePick() async {
    await DatePickerDialogs.show(
      context: context,
      selectedDate: _controller.selectedDate,
      selectedDateMode: _controller.selectedDateMode,
      onDateSelected: (date) => _controller.setSelectedDate(date),
    );
  }

  void _handleFilterDialog() {
    FilterDialog.show(
      context: context,
      selectedDateMode: _controller.selectedDateMode,
      selectedType: _controller.selectedType,
      selectedCategory: _controller.selectedCategory,
      onApply: (dateMode, type, category) {
        _controller.setFilters(dateMode, type, category);
      },
      onReset: () => _controller.resetFilters(),
    );
  }

  void _handleItemTap(DocumentSnapshot doc) {
    if (_controller.isSelecting) {
      _controller.toggleSelection(doc.id);
    } else {
      EditTransactionDialog.show(context, doc);
    }
  }

  void _handleSelectionChanged(String docId, bool selected) {
    if (selected) {
      if (!_controller.selectedIds.contains(docId)) {
        _controller.toggleSelection(docId);
      }
    } else {
      if (_controller.selectedIds.contains(docId)) {
        _controller.toggleSelection(docId);
      }
    }
  }

  Future<void> _handleBulkDelete() async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Hapus Transaksi',
      content:
          'Yakin ingin menghapus ${_controller.selectedIds.length} transaksi?',
    );

    if (confirmed == true) {
      await _controller.bulkDeleteTransactions();
    }
  }
}

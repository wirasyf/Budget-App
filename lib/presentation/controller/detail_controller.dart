import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailController extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'All';
  String _selectedType = 'All';
  String _selectedDateMode = 'Monthly';
  bool _isSelecting = false;
  final Set<String> _selectedIds = {};

  // Getters
  DateTime get selectedDate => _selectedDate;
  String get selectedCategory => _selectedCategory;
  String get selectedType => _selectedType;
  String get selectedDateMode => _selectedDateMode;
  bool get isSelecting => _isSelecting;
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  // Date methods
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Filter methods
  void setFilters(String dateMode, String type, String category) {
    _selectedDateMode = dateMode;
    _selectedType = type;
    _selectedCategory = category;
    notifyListeners();
  }

  void resetFilters() {
    _selectedType = 'All';
    _selectedCategory = 'All';
    _selectedDate = DateTime.now();
    _selectedDateMode = 'Monthly';
    notifyListeners();
  }

  // Selection methods
  void startSelection(String docId) {
    _isSelecting = true;
    _selectedIds.add(docId);
    notifyListeners();
  }

  void toggleSelection(String docId) {
    if (_selectedIds.contains(docId)) {
      _selectedIds.remove(docId);
    } else {
      _selectedIds.add(docId);
    }

    if (_selectedIds.isEmpty) {
      _isSelecting = false;
    }
    notifyListeners();
  }

  void clearSelection() {
    _isSelecting = false;
    _selectedIds.clear();
    notifyListeners();
  }

  // Bulk delete
  Future<void> bulkDeleteTransactions() async {
    if (_selectedIds.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final id in _selectedIds) {
      batch.delete(
        FirebaseFirestore.instance.collection('transactions').doc(id),
      );
    }

    await batch.commit();
    clearSelection();
  }
}

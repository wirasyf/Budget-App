import 'package:flutter/material.dart';
import 'package:budget_app/presentation/theme/color.dart';

class BulkDeleteFab extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPressed;

  const BulkDeleteFab({
    super.key,
    required this.selectedCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: appRed,
      icon: const Icon(Icons.delete, color: Colors.white),
      label: Text(
        'Hapus ($selectedCount)',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

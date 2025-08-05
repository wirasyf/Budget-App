import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget with ThemeHelper {
  final String message;

  const EmptyState({super.key, this.message = 'Tidak ada transaksi.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(color: secondaryTextColor(context)),
      ),
    );
  }
}

import 'package:budget_app/presentation/theme/theme_helper.dart';
import 'package:flutter/material.dart';


class ErrorState extends StatelessWidget with ThemeHelper {
  final String error;

  const ErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Error: $error',
        style: TextStyle(color: primaryTextColor(context)),
      ),
    );
  }
}

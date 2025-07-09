import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Total Balance",
          style: TextStyle(fontSize: 16, color: appBlackSoft),
        ),
        SizedBox(height: 8),
        Text(
          "Rp10.000",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: appBlack,
          ),
        ),
      ],
    );
  }
}

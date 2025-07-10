import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';


class InfoBalance extends StatelessWidget {
  const InfoBalance({
    super.key,
    // ignore: non_constant_identifier_names
    required this.isIncome,
    // ignore: non_constant_identifier_names
    required this.nominal,
  });

  // ignore: non_constant_identifier_names
  final bool isIncome;
  // ignore: non_constant_identifier_names
  final String nominal;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isIncome ? appGreen : appRed,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appWhite,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: isIncome ? Icon(Icons.arrow_downward, color: appGreen, size: 20) : Icon(Icons.arrow_upward, color: appRed, size: 20),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isIncome ? "Income" : "Expense",
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Rp$nominal",
                      style: TextStyle(
                        color: appWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

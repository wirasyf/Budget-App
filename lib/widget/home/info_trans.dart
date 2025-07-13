import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class InfoTransaction extends StatelessWidget {
  const InfoTransaction({
    super.key,
    required this.titleTrans,
    required this.categoryTrans,
    required this.nominalTrans, 
    required this.isExpense,
    this.onTap,
  });

  final bool isExpense;
  final String titleTrans;
  final String categoryTrans;
  final String nominalTrans;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Material(
        color: appBlue,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isExpense ? appGreenSoft : appRedSoft,
                ),
                child: Icon(
                  isExpense ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isExpense ? appGreen : appRed,
                ),
              ),
              title: Text(titleTrans),
              subtitle: Text(categoryTrans),
              trailing: Text(
                isExpense ? "+$nominalTrans" : "-$nominalTrans",
                style: TextStyle(color: isExpense ? appGreen : appRed),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

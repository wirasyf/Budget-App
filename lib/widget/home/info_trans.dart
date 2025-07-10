import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class InfoTransaction extends StatelessWidget {
  const InfoTransaction({
    super.key,
    required this.titleTrans,
    required this.categoryTrans,
    required this.nominalTrans, 
    required this.isExpense,
  });

  final bool isExpense;
  final String titleTrans;
  final String categoryTrans;
  final String nominalTrans;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: appBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isExpense ? appGreenSoft : appRedSoft,
          ),
          child: isExpense
              ? Icon(Icons.arrow_downward, color: appGreen)
              : Icon(Icons.arrow_upward, color: appRed),
        ),
        title: Text(titleTrans),
        subtitle: Text(categoryTrans),
        trailing: Text(
          isExpense ? "+$nominalTrans" : "-$nominalTrans",
          style: TextStyle(color: isExpense ? appGreen : appRed),
        ),
      ),
    );
  }
}

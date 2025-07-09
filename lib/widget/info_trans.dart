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
    return ListTile(
      leading: isExpense
          ? Icon(Icons.arrow_downward, color: appGreen)
          : Icon(Icons.arrow_upward, color: appRed),
      title: Text(titleTrans),
      subtitle: Text(categoryTrans),
      trailing: Text(
        isExpense ? "+$nominalTrans" : "-$nominalTrans",
        style: TextStyle(color: isExpense ? appGreen : appRed),
      ),
    );
  }
}

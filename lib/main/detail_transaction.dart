import 'package:flutter/material.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Detail Transaction Page",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}
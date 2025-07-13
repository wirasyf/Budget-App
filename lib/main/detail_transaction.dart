import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';
import 'package:flutter1/widget/home/info_trans.dart';

class DetailTransaction extends StatefulWidget {
  const DetailTransaction({super.key});

  @override
  State<DetailTransaction> createState() => _DetailTransactionState();
}

class _DetailTransactionState extends State<DetailTransaction> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_drop_down_rounded,
                        size: 30,
                        color: appBlack,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //
                      },
                      child: Text(
                        "July",
                        style: TextStyle(
                          fontSize: 18,
                          color: appBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.filter_list, size: 30, color: appBlack),
              ),
            ],
          ),
        ),

        //Total Balance
        Container(
          margin: const EdgeInsets.all(20),
          child: Material(
            color: appWhiteDark,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // 
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Balance",
                      style: TextStyle(
                        fontSize: 16,
                        color: appBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: appBlack),
                  ],
                ),
              ),
            ),
          ),
        ),

        //Detail Transaksi
        Expanded(
          child: ListView(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today",
                      style: TextStyle(
                        fontSize: 20,
                        color: appBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              InfoTransaction(
                titleTrans: "Ngopi",
                categoryTrans: "Food",
                nominalTrans: "20.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Grocery",
                categoryTrans: "Expense",
                nominalTrans: "5.000",
                isExpense: false,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Rent",
                categoryTrans: "Expense",
                nominalTrans: "3.000",
                isExpense: false,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Freelance",
                categoryTrans: "Income",
                nominalTrans: "8.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Utilities",
                categoryTrans: "Expense",
                nominalTrans: "2.000",
                isExpense: false,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Transport",
                categoryTrans: "Expense",
                nominalTrans: "1.000",
                isExpense: false,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Bonus",
                categoryTrans: "Income",
                nominalTrans: "10.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Dinner",
                categoryTrans: "Food",
                nominalTrans: "15.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Snacks",
                categoryTrans: "Food",
                nominalTrans: "5.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Shopping",
                categoryTrans: "Expense",
                nominalTrans: "50.000",
                isExpense: false,
                onTap: () {
                  //
                },
              ),
              InfoTransaction(
                titleTrans: "Salary",
                categoryTrans: "Income",
                nominalTrans: "2.000.000",
                isExpense: true,
                onTap: () {
                  //
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

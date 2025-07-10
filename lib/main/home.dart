import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';
import 'package:flutter1/widget/home/balance.dart';
import 'package:flutter1/widget/home/date_filter.dart';
import 'package:flutter1/widget/home/info_balance.dart';
import 'package:flutter1/widget/home/info_trans.dart';
import 'package:flutter1/widget/home/recent_section.dart';
import 'package:flutter1/widget/home/up_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: appWhiteDark,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                NavBar(),
                SizedBox(height: 20),
          
                // Balance
                Balance(),
                SizedBox(height: 25),
          
                // Income and Expense 
                Row(
                  children: [
                    InfoBalance(isIncome: true, nominal: "12.000"),
                    InfoBalance(isIncome: false, nominal: "2.000"),
                  ],
                ),
                SizedBox(height: 10),
          
                // Date Filter
                DateFilter(),
          
                // Recent Transactions Section
                RecentSection(),
                SizedBox(height: 10),
          
                // ListView for recent transactions
                Expanded(
                  child: SizedBox(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        InfoTransaction(titleTrans: "Ngopi", categoryTrans: "Food", nominalTrans: "20.000", isExpense: true,),
                        InfoTransaction(titleTrans: "Grocery", categoryTrans: "Expense", nominalTrans: "5.000", isExpense: false,),
                        InfoTransaction(titleTrans: "Rent", categoryTrans: "Expense", nominalTrans: "3.000", isExpense: false,),
                        InfoTransaction(titleTrans: "Freelance", categoryTrans: "Income", nominalTrans: "8.000", isExpense: true,),
                        InfoTransaction(titleTrans: "Utilities", categoryTrans: "Expense", nominalTrans: "2.000", isExpense: false,),
                        InfoTransaction(titleTrans: "Transport", categoryTrans: "Expense", nominalTrans: "1.000", isExpense: false,),
                        InfoTransaction(titleTrans: "Bonus", categoryTrans: "Income", nominalTrans: "10.000", isExpense: true,),
                        InfoTransaction(titleTrans: "Dinner", categoryTrans: "Food", nominalTrans: "15.000", isExpense: true,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}









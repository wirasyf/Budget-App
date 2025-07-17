import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter1/const/color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  DateTime getStartDateByFilter() {
    final now = DateTime.now();
    switch (selectedIndex) {
      case 0:
        return DateTime(now.year, now.month, now.day); // Today
      case 1:
        return now.subtract(Duration(days: now.weekday - 1)); // Start of week
      case 2:
        return DateTime(now.year, now.month); // Start of month
      case 3:
        return DateTime(now.year); // Start of year
      default:
        return DateTime(now.year, now.month, now.day);
    }
  }

  Stream<QuerySnapshot> getTransactions() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final startDate = getStartDateByFilter();

    return FirebaseFirestore.instance
        .collection('transactions')
        .where('uid', isEqualTo: uid)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('date', descending: true)
        .snapshots();
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: appPrimary),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: appPrimary,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.person, size: 20, color: appWhite),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.arrow_drop_down_rounded, size: 30, color: appBlack),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "July",
                            style: TextStyle(fontSize: 18, color: appBlack, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark ? Icons.sunny : Icons.dark_mode,
                      ),
                      iconSize: 28,
                      color: appPrimary,
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Balance
                Column(
                  children: [
                    Text("Total Balance", style: TextStyle(fontSize: 16, color: appBlackSoft)),
                    SizedBox(height: 8),
                    Text("Rp10.000", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: appBlack)),
                  ],
                ),
                SizedBox(height: 25),

                // Income and Expense (dummy)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appGreen,
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
                                child: Icon(Icons.arrow_downward_rounded, color: appGreen, size: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Income", style: TextStyle(color: appWhite, fontSize: 14, fontWeight: FontWeight.w500)),
                                    SizedBox(height: 4),
                                    Text("Rp5.000", style: TextStyle(color: appWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: appRed,
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
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: appRed,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Expended",
                                      style: TextStyle(
                                        color: appWhite,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Rp5.000",
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
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Filter Buttons
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterButton("Today", 0),
                      _buildFilterButton("Week", 1),
                      _buildFilterButton("Month", 2),
                      _buildFilterButton("Year", 3),
                    ],
                  ),
                ),

                // Section Header
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Transaction", style: TextStyle(fontSize: 16, color: appBlack, fontWeight: FontWeight.bold)),
                      Container(
                        decoration: BoxDecoration(color: appVioletSoft, borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () {},
                          child: Text("See All", style: TextStyle(color: appPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),

                // ListView from Firestore
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getTransactions(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text("No transactions"));
                      }

                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final isExpense = data['type'] == 'Expense';
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Material(
                              color: appBlue,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {},
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
                                    title: Text(data['title']),
                                    subtitle: Text(data['category']),
                                    trailing: Text(
                                      "${isExpense ? '+' : '-'}${data['amount'].toString()}",
                                      style: TextStyle(color: isExpense ? appGreen : appRed),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, int index) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: selectedIndex == index ? appYellowSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: selectedIndex == index ? appYellow : appBlackSoft,
            fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

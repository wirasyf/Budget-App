import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:budget_app/const/color.dart';
import 'package:budget_app/screens/add.dart';
import 'package:budget_app/screens/detail_transaction.dart';
import 'package:budget_app/screens/home.dart';
import 'package:budget_app/screens/budget.dart';
import 'package:budget_app/screens/profile.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    DetailTransaction(),
    TransactionFormPage(),
    BudgetingPage(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 60,
        backgroundColor: isDark ? Color(0xFF30363D) : appWhite,
        color: isDark ? Colors.grey[400]! : appGrey,
        activeColor: isDark ? appBlue : appPrimary,
        items: const [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.compare_arrows_rounded, title: 'Details'),
          TabItem(icon: Icons.add_rounded, title: 'Add'),
          TabItem(icon: Icons.pie_chart, title: 'Budget'),
          TabItem(icon: Icons.person_rounded, title: 'Profile'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

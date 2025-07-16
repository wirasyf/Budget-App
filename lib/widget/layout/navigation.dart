import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter1/const/color.dart';
import 'package:flutter1/main/add.dart';
import 'package:flutter1/main/detail_transaction.dart';
import 'package:flutter1/main/home.dart';
import 'package:flutter1/main/notification.dart';
import 'package:flutter1/main/settings.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    DetailTransaction(),
    TransactionFormPage(),
    NotificationPage(),
    Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        height: 60,
        backgroundColor: appWhiteDark,
        color: appGrey,
        activeColor: appPrimary,
        items: [
          TabItem(icon: Icons.home_rounded, title: 'Home'),
          TabItem(icon: Icons.compare_arrows_rounded, title: 'Details'),
          TabItem(icon: Icons.add_rounded, title: 'Add'),
          TabItem(icon: Icons.notifications_rounded, title: 'Notif'),
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

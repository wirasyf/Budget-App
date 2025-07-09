
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class ButtomBar extends StatelessWidget {
  const ButtomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.fixedCircle,
      backgroundColor: appWhite,
      color: appGrey,
      activeColor: appPrimary,
      items: [
        TabItem(icon: Icons.home),
        TabItem(icon: Icons.compare_arrows_outlined),
        TabItem(icon: Icons.add),
        TabItem(icon: Icons.message),
        TabItem(icon: Icons.person),
      ],
    );
  }
}

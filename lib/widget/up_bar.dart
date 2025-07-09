import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        Text(
          "July",
          style: TextStyle(
            fontSize: 18,
            color: appBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications),
          iconSize: 28,
          color: appPrimary,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';


class DateFilter extends StatelessWidget {
  const DateFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: appYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Today",
                style: TextStyle(
                  fontSize: 16,
                  color: appWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "This Week",
              style: TextStyle(fontSize: 16, color: appBlackSoft),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "This Month",
              style: TextStyle(fontSize: 16, color: appBlackSoft),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "This Year",
              style: TextStyle(fontSize: 16, color: appBlackSoft),
            ),
          ),
        ],
      ),
    );
  }
}

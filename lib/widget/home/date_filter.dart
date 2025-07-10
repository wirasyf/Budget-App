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
            width: 80,
            decoration: BoxDecoration(
              color: appYellowSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Today",
                style: TextStyle(
                  fontSize: 16,
                  color: appYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextButton(  
              onPressed: () {},
              child: Text(
                "Week",
                style: TextStyle(fontSize: 16, color: appBlackSoft),
              ),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Month",
              style: TextStyle(fontSize: 16, color: appBlackSoft),
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "Year",
              style: TextStyle(fontSize: 16, color: appBlackSoft),
            ),
          ),
        ],
      ),
    );
  }
}

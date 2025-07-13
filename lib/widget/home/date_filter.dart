import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class DateFilter extends StatefulWidget {
  const DateFilter({super.key});

  @override
  State<DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<DateFilter> {
  int selectedIndex = 0;

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
              color: selectedIndex == 0 ? appYellowSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 0;
                });
              },
              child: Text(
                "Today",
                style: TextStyle(
                  fontSize: 16,
                  color: selectedIndex == 0 ? appYellow : appBlackSoft,
                  fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: selectedIndex == 1 ? appYellowSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 1;
                });
              },
              child: Text(
                "Week",
                style: TextStyle(
                  fontSize: 16, 
                  color: selectedIndex == 1 ? appYellow : appBlackSoft,
                  fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: selectedIndex == 2 ? appYellowSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
              child: Text(
                "Month",
                style: TextStyle(
                  fontSize: 16, 
                  color: selectedIndex == 2 ? appYellow : appBlackSoft,
                  fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: selectedIndex == 3 ? appYellowSoft : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {
                setState(() {
                  selectedIndex = 3;
                });
              },
              child: Text(
                "Year",
                style: TextStyle(
                  fontSize: 16, 
                  color: selectedIndex == 3 ? appYellow : appBlackSoft,
                  fontWeight: selectedIndex == 3 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class RecentSection extends StatelessWidget {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Recent Transaction",
            style: TextStyle(
              fontSize: 16,
              color: appBlack,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: appVioletSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: TextStyle(
                  color: appPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

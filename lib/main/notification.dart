import 'package:flutter/material.dart';
import 'package:flutter1/const/color.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Notifications",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 10,
            itemBuilder: (context, index) {
              return Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: appVioletSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                child: ListTile(
                  title: Text("Notification ${index + 1}"),
                  subtitle: Text("This is the detail of notification ${index + 1}"),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

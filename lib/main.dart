import 'package:flutter/material.dart';
import 'package:flutter1/widget/layout/navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainNavigation(),
    );
  }
}


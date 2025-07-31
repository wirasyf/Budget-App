import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_app/presentation/auth/login.dart';
import 'package:budget_app/presentation/layouts/navigation.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Menunggu state (misalnya sedang login)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Sudah login
        if (snapshot.hasData) {
          return const MainNavigation();
        }

        // 3. Belum login
        return const LoginPage();
      },
    );
  }
}

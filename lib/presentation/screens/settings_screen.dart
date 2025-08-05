import 'dart:convert';
import 'package:budget_app/presentation/widgets/settings/setting_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:budget_app/presentation/auth/login.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;

  String username = "";
  String? base64Image;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// Ambil data user dari Firestore
  Future<void> loadUserData() async {
    if (user == null) return;

    final snapshot = await firestore.collection('users').doc(user!.uid).get();
    if (!mounted) return;
    if (snapshot.exists) {
      setState(() {
        username = snapshot.data()?['username'] ?? '';
        base64Image = snapshot.data()?['photoData'];
      });
    }
  }

  /// Update username di Firestore
  Future<void> updateUsername(String newUsername) async {
    if (user == null) return;

    await firestore.collection('users').doc(user!.uid).set({
      'username': newUsername,
    }, SetOptions(merge: true));
    if (!mounted) return;
    setState(() => username = newUsername);
  }

  /// Ambil gambar dari galeri lalu simpan base64 ke Firestore
  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // compress image
      );

      if (picked != null && user != null) {
        final bytes = await picked.readAsBytes();
        final base64 = base64Encode(bytes);

        // Simpan base64 ke Firestore
        await firestore.collection('users').doc(user!.uid).set({
          'photoData': base64,
        }, SetOptions(merge: true));
        if (!mounted) return;
        setState(() => base64Image = base64);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload gambar: $e')));
    }
  }

  Future<void> _showEditUsernameDialog() async {
    final controller = TextEditingController(text: username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Username"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Enter new username"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await updateUsername(controller.text.trim());
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAboutDialog() async {
    showAboutDialog(
      context: context,
      applicationName: 'Budget App',
      applicationVersion: 'v1.0',
      applicationLegalese: '©2025 Budget App by Wirawrr',
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SettingsWidget(
        user: user,
        username: username,
        base64Image: base64Image,
        onImagePick: pickAndUploadImage,
        onEditUsername: _showEditUsernameDialog,
        onShowAbout: _showAboutDialog,
        onLogout: _logout,
      ),
    );
  }
}

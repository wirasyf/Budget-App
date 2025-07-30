import 'dart:io';
import 'package:flutter/material.dart';
import 'package:budget_app/presentation/auth/login.dart';
import 'package:budget_app/presentation/theme/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  String username = "";
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    if (user == null) return;

    final snapshot = await firestore.collection('users').doc(user!.uid).get();
    if (snapshot.exists) {
      setState(() {
        username = snapshot.data()?['username'] ?? '';
        photoUrl = snapshot.data()?['photoUrl'];
      });
    }
  }

  Future<void> updateUsername(String newUsername) async {
    if (user == null) return;

    await firestore.collection('users').doc(user!.uid).set({
      'username': newUsername,
    }, SetOptions(merge: true));

    setState(() {
      username = newUsername;
    });
  }

  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null && user != null) {
        final ref = storage.ref().child('profile/${user!.uid}.jpg');
        await ref.putFile(File(picked.path));
        final downloadUrl = await ref.getDownloadURL();

        await firestore.collection('users').doc(user!.uid).set({
          'photoUrl': downloadUrl,
        }, SetOptions(merge: true));

        setState(() {
          photoUrl = downloadUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal upload foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      key: ValueKey(photoUrl),
                      radius: 40,
                      backgroundColor: isDark ? appYellow : Colors.blue,
                      backgroundImage: photoUrl != null
                          ? NetworkImage(photoUrl!)
                          : null,
                      child: photoUrl == null
                          ? Icon(Icons.person, size: 50, color: appWhite)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username.isNotEmpty ? username : "No Username",
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?.email ?? "",
                          style: TextStyle(
                            fontSize: 22,
                            color: colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 32,
                      color: isDark ? appYellow : Colors.blue,
                    ),
                    onPressed: () {
                      final controller = TextEditingController(text: username);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Edit Username"),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter new username",
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                await updateUsername(controller.text.trim());
                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    icon: Icons.info,
                    label: "Info Aplikasi",
                    color: isDark ? appYellow : Colors.blue,
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Budget App',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            '© 2025 Budget App by Your Company',
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildSettingItem(
                    icon: Icons.logout,
                    label: "Log Out",
                    color: isDark ? appYellow : Colors.blue,
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(icon, size: 32, color: appPrimary),
              onPressed: onTap,
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: onTap,
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: colorScheme.onBackground),
            ),
          ),
        ],
      ),
    );
  }
}

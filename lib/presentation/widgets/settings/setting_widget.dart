// widgets/settings_widget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:budget_app/presentation/theme/color.dart';

class SettingsWidget extends StatelessWidget {
  final User? user;
  final String username;
  final String? base64Image;
  final VoidCallback onImagePick;
  final VoidCallback onEditUsername;
  final VoidCallback onShowAbout;
  final VoidCallback onLogout;

  const SettingsWidget({
    super.key,
    required this.user,
    required this.username,
    required this.base64Image,
    required this.onImagePick,
    required this.onEditUsername,
    required this.onShowAbout,
    required this.onLogout,
  });

  Widget _buildSettingItem({
    required BuildContext context,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onImagePick,
                  child: CircleAvatar(
                    key: ValueKey(base64Image),
                    radius: 40,
                    backgroundColor: isDark ? appYellow : Colors.blue,
                    backgroundImage: base64Image != null
                        ? MemoryImage(base64Decode(base64Image!))
                        : null,
                    child: base64Image == null
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
                  onPressed: onEditUsername,
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
                  context: context,
                  icon: Icons.info,
                  label: "Info Aplikasi",
                  color: isDark ? appYellow : Colors.blue,
                  onTap: onShowAbout,
                ),
                const SizedBox(height: 30),
                _buildSettingItem(
                  context: context,
                  icon: Icons.logout,
                  label: "Log Out",
                  color: isDark ? appYellow : Colors.blue,
                  onTap: onLogout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

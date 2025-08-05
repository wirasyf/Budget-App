import 'package:flutter/material.dart';
import 'package:budget_app/presentation/theme/color.dart';

mixin ThemeHelper {
  Color backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : Colors.white;
  }

  Color cardBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF161B22) : appPrimary;
  }

  Color primaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }

  Color secondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF8B949E) : appBlackSoft;
  }

  Color appBarBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D1117) : appPrimary;
  }

  Color appBarTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFE6EDF3) : appBlack;
  }
}

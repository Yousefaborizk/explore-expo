import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('ar'));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = prefs.getBool('isDark') ?? false;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;

    final lang = prefs.getString('lang') ?? 'ar';
    locale.value = Locale(lang);
  }

  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
      await prefs.setBool('isDark', true);
    } else {
      themeMode.value = ThemeMode.light;
      await prefs.setBool('isDark', false);
    }
  }

  static Future<void> toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (locale.value.languageCode == 'ar') {
      locale.value = const Locale('en');
      await prefs.setString('lang', 'en');
    } else {
      locale.value = const Locale('ar');
      await prefs.setString('lang', 'ar');
    }
  }
}

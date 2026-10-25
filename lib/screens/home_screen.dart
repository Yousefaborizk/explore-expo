import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_translations.dart';
import '../utils/theme_manager.dart';
import 'portfolio_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.t(context, 'app_name')),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => ThemeManager.toggleLanguage(),
          ),
          IconButton(
            icon: Icon(
              ThemeManager.themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => ThemeManager.toggleTheme(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppTranslations.t(context, 'tagline'),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PortfolioScreen()),
              ),
              icon: const Icon(Icons.work),
              label: Text(AppTranslations.t(context, 'portfolio')),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminScreen()),
              ),
              icon: const Icon(Icons.admin_panel_settings),
              label: Text(AppTranslations.t(context, 'add_work')),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

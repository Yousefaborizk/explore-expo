import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../utils/app_translations.dart';
import '../utils/theme_manager.dart';
import 'app_logo.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 700;

    final Color barColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.85);
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      height: 68,
      decoration: BoxDecoration(
        color: barColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // ===== اللوجو =====
          const SizedBox(width: 16),
          const AppLogo(width: 110, height: 48),
          const SizedBox(width: 8),

          // ===== روابط الصفحات =====
          if (!isMobile) ...[
            const SizedBox(width: 24),
            Expanded(
              child: Row(
                children: [
                  _navItem(context, 0, 'home', Icons.home_outlined),
                  _navItem(
                    context,
                    1,
                    'services',
                    Icons.design_services_outlined,
                  ),
                  _navItem(context, 2, 'works', Icons.work_outline),
                  _navItem(context, 3, 'gallery', Icons.photo_library_outlined),
                  _navItem(context, 4, 'contact', Icons.mail_outline),
                ],
              ),
            ),
          ] else
            const Spacer(),

          // ===== زر اللغة =====
          _iconButton(
            icon: Icons.translate,
            tooltip: AppTranslations.t(context, 'language'),
            onPressed: () => ThemeManager.toggleLanguage(),
          ),

          // ===== زر الثيم =====
          _iconButton(
            icon: isDark ? Icons.light_mode : Icons.dark_mode,
            tooltip: AppTranslations.t(context, 'theme'),
            onPressed: () => ThemeManager.toggleTheme(),
          ),

          // ===== أزرار الدخول / لوحة التحكم =====
          const _AuthButtons(),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    String labelKey,
    IconData icon,
  ) {
    final isActive = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor =
        isDark ? const Color(0xFFF59E0B) : const Color(0xFF1E3A8A);
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : Colors.black.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: isActive
            ? activeColor.withValues(alpha: isDark ? 0.18 : 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onTabChanged(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? activeColor : inactiveColor,
                ),
                const SizedBox(width: 6),
                Text(
                  AppTranslations.t(context, labelKey),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      splashRadius: 20,
    );
  }
}

// ============================================================
// أزرار الدخول / لوحة التحكم / الخروج
// ============================================================
class _AuthButtons extends StatelessWidget {
  const _AuthButtons();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final isLoggedIn = AuthService.isLoggedIn;

        if (isLoggedIn) {
          // ✅ مسجل دخول
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // زرار "لوحة التحكم"
              _TextIconButton(
                icon: Icons.dashboard_outlined,
                label: 'لوحة التحكم',
                onPressed: () => context.go('/admin'),
                color: const Color(0xFF1E3A8A),
              ),

              const SizedBox(width: 8),

              // زرار "خروج"
              _TextIconButton(
                icon: Icons.logout,
                label: 'خروج',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('متأكد إنك عايز تسجل خروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('خروج'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await AuthService.signOut();
                    if (context.mounted) context.go('/');
                  }
                },
                color: Colors.red,
              ),
            ],
          );
        }

        // ❌ مش مسجل
        return _TextIconButton(
          icon: Icons.login,
          label: 'دخول',
          onPressed: () => context.go('/login'),
          color: const Color(0xFF1E3A8A),
        );
      },
    );
  }
}

// ============================================================
// زرار بأيقونة + نص
// ============================================================
class _TextIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _TextIconButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = isDark && color == const Color(0xFF1E3A8A)
        ? const Color(0xFFF59E0B)
        : color;

    return Material(
      color: effectiveColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: effectiveColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_shell.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/auth_gate.dart';
import 'utils/app_colors.dart';
import 'utils/theme_manager.dart';

// ====== إعدادات Supabase ======
const String kSupabaseUrl = 'https://crmsnhbbbkkcyhnjnvxw.supabase.co';
const String kSupabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNybXNuaGJiYmtrY3lobmpudnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI4Nzc2MDEsImV4cCI6MjEwODQ1MzYwMX0.HFMs_jI0ge0vAjBwECp6c1-oGzlqJrtbE1HOw431eHU';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.init();

  await Supabase.initialize(
    url: kSupabaseUrl,
    publishableKey: kSupabaseKey,
  );

  runApp(const ExploreExpoApp());
}

// ====== الراوتر ======
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // الصفحة الرئيسية
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),

    // صفحة أعمالنا مع رقم شركة محدد
    GoRoute(
      path: '/works/:serial',
      builder: (context, state) {
        final serial = int.tryParse(state.pathParameters['serial'] ?? '');
        return HomeShell(worksSerial: serial);
      },
    ),

    // شاشة تسجيل الدخول (مش محمية)
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // لوحة التحكم (محمية بـ AuthGate)
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AuthGate(
        child: AdminDashboardScreen(),
      ),
    ),
  ],
);

class ExploreExpoApp extends StatelessWidget {
  const ExploreExpoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: ThemeManager.locale,
          builder: (context, locale, _) {
            return MaterialApp.router(
              title: 'Explore Expo',
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: const [Locale('en'), Locale('ar')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],

              // ============ Light Theme ============
              theme: ThemeData(
                brightness: Brightness.light,
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: AppColors.background,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: Brightness.light,
                  secondary: AppColors.accent,
                ),
                textTheme: GoogleFonts.cairoTextTheme(),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                cardTheme: CardThemeData(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // ============ Dark Theme ============
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                primaryColor: AppColors.primary,
                scaffoldBackgroundColor: const Color(0xFF0F172A),
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColors.primary,
                  brightness: Brightness.dark,
                  secondary: AppColors.accent,
                ),
                textTheme: GoogleFonts.cairoTextTheme(
                  ThemeData.dark().textTheme,
                ),
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                cardTheme: CardThemeData(
                  elevation: 3,
                  color: const Color(0xFF1E293B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;

  /// المستخدم الحالي (لو مسجل دخول)
  static User? get currentUser => _client.auth.currentUser;

  /// هل مسجل دخول؟
  static bool get isLoggedIn => currentUser != null;

  /// تسجيل دخول
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// تسجيل خروج
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// الاستماع لتغيرات حالة الدخول
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;
}

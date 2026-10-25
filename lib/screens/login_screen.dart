import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late final AnimationController _blobController;
  late final AnimationController _particleController;
  late final AnimationController _rotateController;

  final List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    // دوائر ضبابية
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    // جزيئات طايرة
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // أشكال هندسية بتلف
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // تجهيز الجزيئات
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 4,
        speed: 0.3 + _random.nextDouble() * 0.7,
        opacity: 0.2 + _random.nextDouble() * 0.6,
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _blobController.dispose();
    _particleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.go('/admin');
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _translateAuthError(e.message);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'خطأ غير متوقع: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translateAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'الإيميل أو كلمة المرور غلط';
    }
    if (message.contains('Email not confirmed')) {
      return 'الإيميل مش متأكد منه — فعّل الإيميل أو أعد إنشاء الحساب بـ Auto Confirm';
    }
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ===== الخلفية المتدرجة =====
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF0F172A),
                        Color(0xFF1E1B4B),
                        Color(0xFF0F172A),
                      ]
                    : const [
                        Color(0xFFF0F9FF),
                        Color(0xFFE0E7FF),
                        Color(0xFFFEF3C7),
                      ],
              ),
            ),
          ),

          // ===== دوائر ضبابية ملونة =====
          AnimatedBuilder(
            animation: _blobController,
            builder: (context, _) {
              final t = _blobController.value * 2 * math.pi;
              return Stack(
                children: [
                  _buildBlob(
                    alignment: Alignment(
                      -0.7 + 0.3 * math.sin(t),
                      -0.7 + 0.2 * math.cos(t),
                    ),
                    size: 400,
                    color: isDark
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                        : const Color(0xFF60A5FA).withValues(alpha: 0.45),
                  ),
                  _buildBlob(
                    alignment: Alignment(
                      0.8 + 0.2 * math.cos(t + 1),
                      0.6 + 0.3 * math.sin(t + 1),
                    ),
                    size: 380,
                    color: isDark
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                        : const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  ),
                  _buildBlob(
                    alignment: Alignment(
                      0.1 * math.sin(t + 2),
                      0.3 * math.cos(t + 2),
                    ),
                    size: 300,
                    color: isDark
                        ? const Color(0xFFEC4899).withValues(alpha: 0.35)
                        : const Color(0xFFF472B6).withValues(alpha: 0.4),
                  ),
                  _buildBlob(
                    alignment: Alignment(
                      -0.5 + 0.2 * math.cos(t + 3),
                      0.7 + 0.2 * math.sin(t + 3),
                    ),
                    size: 260,
                    color: isDark
                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                        : const Color(0xFF34D399).withValues(alpha: 0.4),
                  ),
                ],
              );
            },
          ),

          // ===== أشكال هندسية بتلف =====
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, _) {
              final rot = _rotateController.value * 2 * math.pi;
              return Stack(
                children: [
                  // مثلث
                  Positioned(
                    top: 80,
                    right: 60,
                    child: Transform.rotate(
                      angle: rot,
                      child: CustomPaint(
                        size: const Size(60, 60),
                        painter: _TrianglePainter(
                          color: isDark
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                              : const Color(0xFF1E3A8A).withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                  // مربع
                  Positioned(
                    bottom: 100,
                    left: 80,
                    child: Transform.rotate(
                      angle: -rot,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF10B981).withValues(alpha: 0.5)
                                : const Color(0xFF14B8A6)
                                    .withValues(alpha: 0.4),
                            width: 2.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  // دايرة
                  Positioned(
                    top: 200,
                    left: 40,
                    child: Transform.rotate(
                      angle: rot * 0.5,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFFEC4899).withValues(alpha: 0.5)
                                : const Color(0xFFF472B6)
                                    .withValues(alpha: 0.4),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // زائد
                  Positioned(
                    bottom: 200,
                    right: 80,
                    child: Transform.rotate(
                      angle: rot,
                      child: Icon(
                        Icons.add,
                        size: 50,
                        color: isDark
                            ? const Color(0xFF3B82F6).withValues(alpha: 0.4)
                            : const Color(0xFF6366F1).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // ===== جزيئات طايرة =====
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlesPainter(
                  particles: _particles,
                  progress: _particleController.value,
                  color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                ),
              );
            },
          ),

          // ===== نجوم بتلمع =====
          ..._buildStars(isDark),

          // ===== المحتوى =====
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildCard(context, isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStars(bool isDark) {
    final stars = <Widget>[];
    final positions = [
      const Offset(0.1, 0.15),
      const Offset(0.9, 0.2),
      const Offset(0.15, 0.75),
      const Offset(0.85, 0.8),
      const Offset(0.5, 0.1),
      const Offset(0.05, 0.45),
      const Offset(0.95, 0.55),
    ];
    for (int i = 0; i < positions.length; i++) {
      stars.add(
        Positioned(
          left: MediaQuery.of(context).size.width * positions[i].dx,
          top: MediaQuery.of(context).size.height * positions[i].dy,
          child: Icon(
            Icons.star,
            size: 12 + (i % 3) * 6,
            color: isDark
                ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                : const Color(0xFF6366F1).withValues(alpha: 0.4),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fadeIn(duration: 1200.ms, delay: (i * 200).ms)
              .then()
              .fadeOut(duration: 1200.ms),
        ),
      );
    }
    return stars;
  }

  Widget _buildBlob({
    required Alignment alignment,
    required double size,
    required Color color,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.9),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
            blurRadius: 50,
            offset: const Offset(0, 25),
          ),
          BoxShadow(
            color: (isDark ? const Color(0xFF3B82F6) : const Color(0xFF6366F1))
                .withValues(alpha: 0.15),
            blurRadius: 60,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== اللوجو =====
            const Center(
              child: AppLogo(width: 160, height: 80),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 24),

            Text(
              'أهلاً بعودتك 👋',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 8),

            Text(
              'سجّل دخولك للوصول للوحة التحكم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: 32),

            _buildField(
              isDark: isDark,
              controller: _emailController,
              icon: Icons.email_outlined,
              label: 'الإيميل',
              hint: 'admin@exploreexpo.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'أدخل الإيميل';
                if (!v.contains('@')) return 'إيميل غير صحيح';
                return null;
              },
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideX(begin: -0.1),

            const SizedBox(height: 16),

            _buildField(
              isDark: isDark,
              controller: _passwordController,
              icon: Icons.lock_outline,
              label: 'كلمة المرور',
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                return null;
              },
              onFieldSubmitted: (_) => _loading ? null : _login(),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 400.ms)
                .slideX(begin: -0.1),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().shakeX(),
            ],

            const SizedBox(height: 28),

            SizedBox(
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                        : [const Color(0xFF1E3A8A), const Color(0xFF6366F1)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF1E3A8A))
                          .withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.login, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'دخول',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 500.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: _loading ? null : () => context.go('/'),
              icon: Icon(
                Icons.arrow_back,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              label: Text(
                'العودة للصفحة الرئيسية',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05);
  }

  Widget _buildField({
    required bool isDark,
    required TextEditingController controller,
    required IconData icon,
    required String label,
    String? hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !_loading,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
        labelStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
        ),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.03),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF1E3A8A),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}

// ============================================================
// Particle
// ============================================================
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final dy = (p.y - progress * p.speed) % 1.0;
      final dx = p.x + 0.05 * math.sin(progress * 2 * math.pi + p.x * 10);
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}

// ============================================================
// Triangle Painter
// ============================================================
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}

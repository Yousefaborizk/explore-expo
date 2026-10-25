import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgTop =
        isDark ? const Color(0xFF0B1220) : const Color(0xFFF8FAFC);
    final Color bgBottom =
        isDark ? const Color(0xFF101A33) : const Color(0xFFE0E7FF);

    final Color blob1 = isDark
        ? const Color(0xFF3B82F6).withValues(alpha: 0.28)
        : const Color(0xFF6366F1).withValues(alpha: 0.22);

    final Color blob2 = isDark
        ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
        : const Color(0xFFF59E0B).withValues(alpha: 0.18);

    final Color blob3 = isDark
        ? const Color(0xFF10B981).withValues(alpha: 0.18)
        : const Color(0xFF14B8A6).withValues(alpha: 0.15);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgTop, bgBottom],
        ),
      ),
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;
              return Stack(
                children: [
                  _buildBlob(
                    alignment: Alignment(
                      -0.6 + 0.2 * math.sin(t),
                      -0.7 + 0.15 * math.cos(t),
                    ),
                    size: 320,
                    color: blob1,
                  ),
                  _buildBlob(
                    alignment: Alignment(
                      0.7 + 0.15 * math.cos(t + 1),
                      0.6 + 0.2 * math.sin(t + 1),
                    ),
                    size: 280,
                    color: blob2,
                  ),
                  _buildBlob(
                    alignment: Alignment(
                      0.2 * math.sin(t + 2),
                      0.3 * math.cos(t + 2),
                    ),
                    size: 220,
                    color: blob3,
                  ),
                ],
              );
            },
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GridPainter(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.035),
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
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
}

class _GridPainter extends CustomPainter {
  final Color color;

  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const step = 40.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color;
}

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  /// العرض (لو مش محدد، بياخد نفس قيمة height)
  final double? width;

  /// الارتفاع (لو مش محدد، بياخد نفس قيمة width)
  final double? height;

  /// لو true، بيضيف ظل خفيف حواليه
  final bool withShadow;

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.withShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    // لو الاتنين null، نستخدم قيمة افتراضية
    final double w = width ?? height ?? 36;
    final double h = height ?? width ?? 36;

    final image = Image.asset(
      'assets/images/logo.png',
      width: w,
      height: h,
      // contain عشان اللوجو يبان كامل من غير قص ولا تشويه
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => SizedBox(
        width: w,
        height: h,
        child: Icon(
          Icons.explore,
          size: (w < h ? w : h) * 0.85,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    if (!withShadow) return image;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: image,
    );
  }
}

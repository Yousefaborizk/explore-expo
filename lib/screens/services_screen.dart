import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_translations.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final services = [
      {
        'icon': Icons.event,
        'title': 'تنظيم المعارض',
        'desc': 'تنظيم شامل من التخطيط للتنفيذ',
      },
      {
        'icon': Icons.design_services,
        'title': 'تصميم الأجنحة',
        'desc': 'أجنحة عرض احترافية وجذابة',
      },
      {
        'icon': Icons.campaign,
        'title': 'التسويق والدعاية',
        'desc': 'خطط تسويقية فعّالة للوصول لأكبر جمهور',
      },
      {
        'icon': Icons.groups,
        'title': 'إدارة الفعاليات',
        'desc': 'إدارة كاملة للمؤتمرات والفعاليات',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTranslations.t(context, 'services'),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 900 ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio:
                MediaQuery.of(context).size.width > 900 ? 2.2 : 3.2,
            children: List.generate(services.length, (i) {
              final s = services[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF1E3A8A))
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        s['icon'] as IconData,
                        color: isDark
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s['desc'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.1);
            }),
          ),
        ],
      ),
    );
  }
}

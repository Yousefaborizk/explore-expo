import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../models/company.dart';
import '../services/company_service.dart';
import '../utils/app_translations.dart';

class HomeContent extends StatefulWidget {
  /// callback للتنقل بين التابات في الـ HomeShell
  final void Function(int index)? onNavigateToTab;

  const HomeContent({super.key, this.onNavigateToTab});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late Future<List<Company>> _companiesFuture;

  @override
  void initState() {
    super.initState();
    _companiesFuture = CompanyService.fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHero(context, isDark, isMobile),
          const SizedBox(height: 60),
          _buildStats(context, isDark),
          const SizedBox(height: 60),
          _buildMiniServices(context, isDark, isMobile),
          const SizedBox(height: 60),
          _buildFeaturedCompanies(context, isDark, isMobile),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ============================================================
  // Hero
  // ============================================================
  Widget _buildHero(BuildContext context, bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: 40,
      ),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                  : const Color(0xFF1E3A8A).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                    : const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF1E3A8A),
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore Expo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.3),

          const SizedBox(height: 24),

          Text(
            AppTranslations.t(context, 'tagline'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 32 : 52,
              fontWeight: FontWeight.bold,
              height: 1.15,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          )
              .animate()
              .fadeIn(duration: 700.ms, delay: 100.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              'بنحوّل أفكارك لمعارض متتنسيش — من التخطيط للتنفيذ، إحنا معاك في كل خطوة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 15 : 17,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.6,
              ),
            ).animate().fadeIn(duration: 700.ms, delay: 200.ms),
          ),

          const SizedBox(height: 40),

          // ===== أزرار CTA =====
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              // اكتشف أعمالنا → tab 2
              _CtaButton(
                label: 'اكتشف أعمالنا',
                icon: Icons.explore_outlined,
                isPrimary: true,
                isDark: isDark,
                onTap: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(2); // works
                  } else {
                    context.go('/works');
                  }
                },
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.2),

              // تواصل معنا → tab 4
              _CtaButton(
                label: 'تواصل معنا',
                icon: Icons.chat_bubble_outline,
                isPrimary: false,
                isDark: isDark,
                onTap: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(4); // contact
                  } else {
                    context.go('/contact');
                  }
                },
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms)
                  .slideY(begin: 0.2),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // إحصائيات
  // ============================================================
  Widget _buildStats(BuildContext context, bool isDark) {
    final stats = [
      _StatData(
        value: 150,
        suffix: '+',
        label: 'معرض منظم',
        icon: Icons.event,
        color: const Color(0xFF3B82F6),
      ),
      _StatData(
        value: 50,
        suffix: '+',
        label: 'عميل سعيد',
        icon: Icons.people,
        color: const Color(0xFF10B981),
      ),
      _StatData(
        value: 10,
        suffix: '+',
        label: 'سنوات خبرة',
        icon: Icons.workspace_premium,
        color: const Color(0xFFF59E0B),
      ),
      _StatData(
        value: 200,
        suffix: '+',
        label: 'فعالية',
        icon: Icons.celebration,
        color: const Color(0xFFEC4899),
      ),
    ];

    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: stats.asMap().entries.map((e) {
          return _StatCard(
            data: e.value,
            isDark: isDark,
            delay: e.key * 100,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // خدمات مصغرة
  // ============================================================
  Widget _buildMiniServices(BuildContext context, bool isDark, bool isMobile) {
    final services = [
      {
        'icon': Icons.event,
        'title': 'تنظيم المعارض',
        'desc': 'من الفكرة للتنفيذ',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.design_services,
        'title': 'تصميم الأجنحة',
        'desc': 'أجنحة احترافية',
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.campaign,
        'title': 'التسويق والدعاية',
        'desc': 'خطط تسويقية فعّالة',
        'color': const Color(0xFFF59E0B),
      },
      {
        'icon': Icons.groups,
        'title': 'إدارة الفعاليات',
        'desc': 'إدارة كاملة',
        'color': const Color(0xFFEC4899),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                        : [const Color(0xFF1E3A8A), const Color(0xFF6366F1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'خدماتنا',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(1); // services
                  } else {
                    context.go('/services');
                  }
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('الكل'),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: isMobile ? 1 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isMobile ? 3.5 : 1.1,
            children: services.asMap().entries.map((e) {
              final s = e.value;
              final color = s['color'] as Color;
              return _MiniServiceCard(
                icon: s['icon'] as IconData,
                title: s['title'] as String,
                desc: s['desc'] as String,
                color: color,
                isDark: isDark,
                delay: e.key * 100,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // شركات مميزة
  // ============================================================
  Widget _buildFeaturedCompanies(
      BuildContext context, bool isDark, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                        : [const Color(0xFF1E3A8A), const Color(0xFF6366F1)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'شركات مميزة',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  if (widget.onNavigateToTab != null) {
                    widget.onNavigateToTab!(2); // works
                  } else {
                    context.go('/works');
                  }
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('كل الأعمال'),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.2),
          const SizedBox(height: 20),
          FutureBuilder<List<Company>>(
            future: _companiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildCompanySkeletons(isDark, isMobile);
              }

              if (snapshot.hasError) {
                return _buildErrorState(
                  context,
                  isDark,
                  'مش قادرين نجيب الشركات',
                  () => setState(() {
                    _companiesFuture = CompanyService.fetchAll();
                  }),
                );
              }

              final companies = snapshot.data ?? [];

              if (companies.isEmpty) {
                return _buildEmptyState(isDark);
              }

              final featured = companies.take(3).toList();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isMobile ? 2.5 : 1.0,
                ),
                itemCount: featured.length,
                itemBuilder: (context, i) {
                  return _FeaturedCompanyCard(
                    company: featured[i],
                    isDark: isDark,
                    delay: i * 150,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Loading Skeleton
  // ============================================================
  Widget _buildCompanySkeletons(bool isDark, bool isMobile) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 2.5 : 1.0,
      ),
      itemCount: 3,
      itemBuilder: (context, i) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 1200.ms,
                    color: isDark ? Colors.white24 : Colors.white,
                  ),
              const SizedBox(height: 16),
              Container(
                width: 120,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 1200.ms,
                    color: isDark ? Colors.white24 : Colors.white,
                  ),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 1200.ms,
                    color: isDark ? Colors.white24 : Colors.white,
                  ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // خطأ
  // ============================================================
  Widget _buildErrorState(
    BuildContext context,
    bool isDark,
    String message,
    VoidCallback onRetry,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off,
            size: 48,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // لا يوجد بيانات
  // ============================================================
  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.business_outlined,
            size: 48,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          const SizedBox(height: 12),
          Text(
            'لسه مفيش شركات — أضف شركات من لوحة التحكم',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CTA Button
// ============================================================
class _CtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDark;
  final VoidCallback onTap;

  const _CtaButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        height: 56,
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
              color:
                  (isDark ? const Color(0xFFF59E0B) : const Color(0xFF1E3A8A))
                      .withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Stat Data + Card
// ============================================================
class _StatData {
  final int value;
  final String suffix;
  final String label;
  final IconData icon;
  final Color color;

  _StatData({
    required this.value,
    required this.suffix,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatefulWidget {
  final _StatData data;
  final bool isDark;
  final int delay;

  const _StatCard({
    required this.data,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<int> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _countAnimation = IntTween(begin: 0, end: widget.data.value)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cardWidth = w > 1000 ? 220.0 : (w > 700 ? 180.0 : 150.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.data.color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.data.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.data.icon,
              color: widget.data.color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, _) {
              return Text(
                '${_countAnimation.value}${widget.data.suffix}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.data.color,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.data.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: widget.isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: widget.delay.ms)
        .slideY(begin: 0.2);
  }
}

// ============================================================
// Mini Service Card
// ============================================================
class _MiniServiceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final bool isDark;
  final int delay;

  const _MiniServiceCard({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_MiniServiceCard> createState() => _MiniServiceCardState();
}

class _MiniServiceCardState extends State<_MiniServiceCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.1 : 0.06)
              : Colors.white.withValues(alpha: _hovered ? 1 : 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: 0.5)
                : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.desc,
              style: TextStyle(
                fontSize: 12,
                color: widget.isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: widget.delay.ms)
        .slideY(begin: 0.2);
  }
}

// ============================================================
// Featured Company Card
// ============================================================
class _FeaturedCompanyCard extends StatefulWidget {
  final Company company;
  final bool isDark;
  final int delay;

  const _FeaturedCompanyCard({
    required this.company,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_FeaturedCompanyCard> createState() => _FeaturedCompanyCardState();
}

class _FeaturedCompanyCardState extends State<_FeaturedCompanyCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final serial = widget.company.serialNumber ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.1 : 0.06)
              : Colors.white.withValues(alpha: _hovered ? 1 : 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? (widget.isDark
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.5)
                    : const Color(0xFF1E3A8A).withValues(alpha: 0.4))
                : (widget.isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05)),
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: (widget.isDark
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF1E3A8A))
                        .withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.go('/works/$serial'),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isDark
                            ? [
                                const Color(0xFFF59E0B),
                                const Color(0xFFEF4444),
                              ]
                            : [
                                const Color(0xFF1E3A8A),
                                const Color(0xFF6366F1),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      serial.toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (widget.company.logoUrl != null &&
                      widget.company.logoUrl!.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        widget.company.logoUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.business,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    widget.company.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.isDark
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        size: 12,
                        color: widget.isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/#/works/$serial',
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color:
                              widget.isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: widget.delay.ms)
        .slideY(begin: 0.2);
  }
}

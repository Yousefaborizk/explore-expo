import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_translations.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  // ============================================================
  // بيانات التواصل
  // ============================================================
  static const String _address = '١١ عمارات العبور، صلاح سالم، القاهرة';
  static const String _phone1 = '01010535329';
  static const String _phone2 = '01553539420';
  static const String _email = 'gads50141@gmail.com';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 60,
        vertical: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== العنوان الرئيسي =====
          Row(
            children: [
              Container(
                width: 4,
                height: 32,
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
                AppTranslations.t(context, 'contact'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.2),

          const SizedBox(height: 8),

          Text(
            'نحن هنا للإجابة على استفساراتك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 32),

          // ===== كارت العنوان =====
          _ContactCard(
            icon: Icons.location_on_outlined,
            title: 'العنوان',
            value: _address,
            color: const Color(0xFFEF4444),
            isDark: isDark,
            delay: 200,
            onTap: () => _openMap(),
          ),

          const SizedBox(height: 16),

          // ===== كارت التليفونات =====
          _ContactCard(
            icon: Icons.phone_outlined,
            title: 'الهاتف',
            value: '$_phone1\n$_phone2',
            color: const Color(0xFF10B981),
            isDark: isDark,
            delay: 300,
            onTap: () => _showPhoneOptions(context, isDark),
          ),

          const SizedBox(height: 16),

          // ===== كارت الإيميل =====
          _ContactCard(
            icon: Icons.email_outlined,
            title: 'البريد الإلكتروني',
            value: _email,
            color: const Color(0xFF3B82F6),
            isDark: isDark,
            delay: 400,
            onTap: () => _sendEmail(),
          ),

          const SizedBox(height: 32),

          // ===== أزرار تواصل سريع =====
          Text(
            'تواصل سريع',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _QuickAction(
                icon: Icons.phone,
                label: 'اتصل بينا',
                color: const Color(0xFF10B981),
                isDark: isDark,
                onTap: () => _makeCall(_phone1),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              _QuickAction(
                icon: Icons.email,
                label: 'ابعت إيميل',
                color: const Color(0xFF3B82F6),
                isDark: isDark,
                onTap: () => _sendEmail(),
              ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.1),
              _QuickAction(
                icon: Icons.location_on,
                label: 'افتح الخريطة',
                color: const Color(0xFFEF4444),
                isDark: isDark,
                onTap: () => _openMap(),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1),
              _QuickAction(
                icon: Icons.chat,
                label: 'واتساب',
                color: const Color(0xFF25D366),
                isDark: isDark,
                onTap: () => _openWhatsApp(),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1),
            ],
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // ============================================================
  // فتح الخريطة
  // ============================================================
  Future<void> _openMap() async {
    final query = Uri.encodeComponent(_address);
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // اتصال
  // ============================================================
  Future<void> _makeCall(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // إيميل
  // ============================================================
  Future<void> _sendEmail() async {
    final url = Uri.parse(
      'mailto:$_email?subject=استفسار من الموقع&body=مرحباً،',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // واتساب
  // ============================================================
  Future<void> _openWhatsApp() async {
    // نحول الرقم لصيغة دولية: 01010535329 → 201010535329
    final phone = _phone1.replaceFirst('0', '20');
    final url = Uri.parse('https://wa.me/$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // Dialog اختيار الرقم
  // ============================================================
  Future<void> _showPhoneOptions(BuildContext context, bool isDark) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اتصل بنا'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PhoneOption(
              label: _phone1,
              isDark: isDark,
              onTap: () => Navigator.pop(ctx, _phone1),
            ),
            const SizedBox(height: 8),
            _PhoneOption(
              label: _phone2,
              isDark: isDark,
              onTap: () => Navigator.pop(ctx, _phone2),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );

    if (selected != null) {
      await _makeCall(selected);
    }
  }
}

// ============================================================
// Contact Card
// ============================================================
class _ContactCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;
  final int delay;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<_ContactCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: widget.isDark
              ? Colors.white.withValues(alpha: _hovered ? 0.1 : 0.06)
              : Colors.white.withValues(alpha: _hovered ? 1 : 0.9),
          borderRadius: BorderRadius.circular(16),
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
                    color: widget.color.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                widget.isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: widget.isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: widget.color,
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
        .slideY(begin: 0.1);
  }
}

// ============================================================
// Quick Action
// ============================================================
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Phone Option (في الـ Dialog)
// ============================================================
class _PhoneOption extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _PhoneOption({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone, size: 18, color: Color(0xFF10B981)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

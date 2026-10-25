import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/photo.dart';
import '../services/photo_service.dart';
import '../utils/app_translations.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  late Future<List<PhotoItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = PhotoService.fetchAll();
  }

  void _reload() {
    setState(() {
      _future = PhotoService.fetchAll();
    });
  }

  void _openFullScreen(PhotoItem photo) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // الصورة كاملة
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(
                  photo.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            // زر الإغلاق
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            // العنوان
            if (photo.title != null && photo.title!.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      photo.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<PhotoItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'خطأ في تحميل الصور\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        final photos = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== العنوان =====
              Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 32,
                    color: isDark
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF1E3A8A),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslations.t(context, 'gallery'),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'إعادة تحميل',
                    icon: const Icon(Icons.refresh),
                    onPressed: _reload,
                  ),
                ],
              ).animate().fadeIn().slideX(begin: -0.2),

              const SizedBox(height: 8),

              Text(
                photos.isEmpty
                    ? 'لقطات من معارض نظمناها'
                    : '${photos.length} صورة من معارضنا',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 24),

              // ===== مفيش صور =====
              if (photos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
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
                  child: Column(
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 48,
                        color: isDark ? Colors.white38 : Colors.black26,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد صور بعد',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'أضف صور من لوحة التحكم',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _MasonryGallery(
                  photos: photos,
                  isDark: isDark,
                  onTap: _openFullScreen,
                ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// Masonry Grid للصور
// ============================================================
class _MasonryGallery extends StatelessWidget {
  final List<PhotoItem> photos;
  final bool isDark;
  final void Function(PhotoItem) onTap;

  const _MasonryGallery({
    required this.photos,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 3 أعمدة على الشاشات الكبيرة، 2 على المتوسطة، 1 على الموبايل
    final columns = width > 1100
        ? 3
        : width > 700
            ? 2
            : 1;

    // نقسم الصور على الأعمدة
    final List<List<PhotoItem>> cols =
        List.generate(columns, (_) => <PhotoItem>[]);

    for (int i = 0; i < photos.length; i++) {
      cols[i % columns].add(photos[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: cols.map((col) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                for (int i = 0; i < col.length; i++)
                  _GalleryCard(
                    photo: col[i],
                    isDark: isDark,
                    // ارتفاعات مختلفة عشان يبان masonry
                    heightVariant: i % 3,
                    delay: i * 80,
                    onTap: () => onTap(col[i]),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// كارد صورة
// ============================================================
class _GalleryCard extends StatelessWidget {
  final PhotoItem photo;
  final bool isDark;
  final int heightVariant;
  final int delay;
  final VoidCallback onTap;

  const _GalleryCard({
    required this.photo,
    required this.isDark,
    required this.heightVariant,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final heights = [260.0, 200.0, 320.0];
    final height = heights[heightVariant % heights.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.black12,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // الصورة
                Image.network(
                  photo.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: isDark ? Colors.white38 : Colors.black26,
                    ),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                progress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),

                // Overlay تدريجي من تحت
                if (photo.title != null && photo.title!.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                      child: Text(
                        photo.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // أيقونة تكبير (Hover effect بسيط)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.zoom_in,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1),
    );
  }
}

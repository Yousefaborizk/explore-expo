import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import '../models/company.dart';
import '../models/video.dart';
import '../services/company_service.dart';
import '../services/video_service.dart';
import '../utils/app_translations.dart';

class WorksScreen extends StatefulWidget {
  final int? scrollToSerial;

  const WorksScreen({super.key, this.scrollToSerial});

  @override
  State<WorksScreen> createState() => _WorksScreenState();
}

class _WorksScreenState extends State<WorksScreen> {
  late Future<_WorksData> _future;
  final Map<String, GlobalKey> _companyKeys = {};
  final Map<String, bool> _expanded = {};
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _didAutoScroll = false;

  // 🔑 نخزن الفيديوهات بعد ما تحمل مرة واحدة
  Map<String, List<VideoItem>> _videosByCompany = {};

  @override
  void initState() {
    super.initState();
    _future = _loadAll();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_WorksData> _loadAll() async {
    final companies = await CompanyService.fetchAll();

    for (final c in companies) {
      _companyKeys[c.id] = GlobalKey();
    }

    final videosByCompany = <String, List<VideoItem>>{};
    for (final c in companies) {
      videosByCompany[c.id] = await VideoService.fetchByCompany(c.id);
    }

    return _WorksData(companies: companies, videosByCompany: videosByCompany);
  }

  void _autoScrollToCompany(List<Company> companies) {
    if (_didAutoScroll) return;
    if (widget.scrollToSerial == null) return;
    if (!mounted) return;

    _didAutoScroll = true;

    final target = companies.firstWhere(
      (c) => c.serialNumber == widget.scrollToSerial,
      orElse: () => companies.first,
    );

    setState(() {
      _expanded[target.id] = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _companyKeys[target.id]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      }
    });
  }

  void _toggleExpand(String companyId) {
    setState(() {
      _expanded[companyId] = !(_expanded[companyId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return FutureBuilder<_WorksData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data;
        final allCompanies = data?.companies ?? [];

        // 🔑 نحدّث _videosByCompany بعد ما البيانات تجي
        if (data != null && _videosByCompany.isEmpty) {
          _videosByCompany = data.videosByCompany;
        }

        if (allCompanies.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoScrollToCompany(allCompanies);
          });
        }

        final companies = allCompanies.where((c) {
          if (_searchQuery.isEmpty) return true;
          final q = _searchQuery.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
              (c.serialNumber?.toString() ?? '').contains(q);
        }).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 40,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark, allCompanies.length),
              const SizedBox(height: 20),
              _buildSearchBar(context, isDark),
              const SizedBox(height: 24),
              if (companies.isEmpty)
                _buildEmptyState(context, isDark)
              else
                _buildLogoGrid(context, isDark, isMobile, companies),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // Header
  // ============================================================
  Widget _buildHeader(BuildContext context, bool isDark, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 36,
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
              AppTranslations.t(context, 'works'),
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: -0.2),
        const SizedBox(height: 8),
        Text(
          '$total شركة — اضغط على أي شركة لعرض فيديوهاتها',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  // ============================================================
  // شريط البحث
  // ============================================================
  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
        ),
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو الرقم...',
          hintStyle: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 150.ms);
  }

  // ============================================================
  // Grid اللوجوهات
  // ============================================================
  Widget _buildLogoGrid(
    BuildContext context,
    bool isDark,
    bool isMobile,
    List<Company> companies,
  ) {
    final hasExpanded = companies.any((c) => _expanded[c.id] == true);

    if (hasExpanded) {
      return Column(
        children: companies.asMap().entries.map((entry) {
          return _buildCompanySection(
            context,
            isDark,
            entry.value,
            entry.key,
          );
        }).toList(),
      );
    }

    final crossAxisCount = isMobile ? 2 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: companies.length,
      itemBuilder: (context, i) {
        return _LogoCard(
          company: companies[i],
          isDark: isDark,
          delay: i * 80,
          onTap: () => _toggleExpand(companies[i].id),
        );
      },
    );
  }

  // ============================================================
  // قسم الشركة (لما تتفتح)
  // ============================================================
  Widget _buildCompanySection(
    BuildContext context,
    bool isDark,
    Company company,
    int index,
  ) {
    final videos = _videosByCompany[company.id] ?? [];
    final isExpanded = _expanded[company.id] == true;

    return Container(
      key: _companyKeys[company.id],
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExpandedHeader(context, isDark, company, isExpanded),
          if (isExpanded) _buildVideosSection(company, videos, isDark),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1);
  }

  Widget _buildExpandedHeader(
    BuildContext context,
    bool isDark,
    Company company,
    bool isExpanded,
  ) {
    final serial = company.serialNumber ?? 0;

    return InkWell(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      onTap: () => _toggleExpand(company.id),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: company.logoUrl != null && company.logoUrl!.isNotEmpty
                  ? Image.network(
                      company.logoUrl!,
                      fit: BoxFit.contain,
                    )
                  : const Icon(Icons.business, color: Colors.black26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (company.description != null &&
                      company.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        company.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                      : [const Color(0xFF1E3A8A), const Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                serial.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  // 🔑 بقت بتاخد الفيديوهات من _videosByCompany مش من FutureBuilder
  Widget _buildVideosSection(
    Company company,
    List<VideoItem> videos,
    bool isDark,
  ) {
    if (videos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.videocam_off,
              size: 18,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            const SizedBox(width: 8),
            Text(
              'لا توجد فيديوهات لهذه الشركة',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: videos.asMap().entries.map((e) {
          return _VideoCard(
            video: e.value,
            isDark: isDark,
            delay: e.key * 80,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // لا نتائج
  // ============================================================
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDark ? Colors.white38 : Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty
                  ? 'لا توجد شركات بعد'
                  : 'لا توجد نتائج لـ "$_searchQuery"',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// بيانات مجمعة
// ============================================================
class _WorksData {
  final List<Company> companies;
  final Map<String, List<VideoItem>> videosByCompany;

  _WorksData({required this.companies, required this.videosByCompany});
}

// ============================================================
// كارت اللوجو (Grid item)
// ============================================================
class _LogoCard extends StatefulWidget {
  final Company company;
  final bool isDark;
  final int delay;
  final VoidCallback onTap;

  const _LogoCard({
    required this.company,
    required this.isDark,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_LogoCard> createState() => _LogoCardState();
}

class _LogoCardState extends State<_LogoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final serial = widget.company.serialNumber ?? 0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: widget.isDark
                ? Colors.white.withValues(alpha: _hovered ? 0.1 : 0.06)
                : Colors.white.withValues(alpha: _hovered ? 1 : 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovered
                  ? (widget.isDark
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                      : const Color(0xFF1E3A8A).withValues(alpha: 0.4))
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05)),
              width: _hovered ? 2 : 1,
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
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.isDark
                          ? [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
                          : [
                              const Color(0xFF1E3A8A),
                              const Color(0xFF6366F1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    serial.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: _hovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.company.logoUrl != null &&
                                widget.company.logoUrl!.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.network(
                                  widget.company.logoUrl!,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Icon(
                                Icons.business,
                                color: Colors.black26,
                                size: 32,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.company.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark
                            ? Colors.white
                            : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Icon(
                  Icons.open_in_full,
                  size: 14,
                  color: widget.isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: widget.delay.ms)
        .scale(begin: const Offset(0.9, 0.9));
  }
}

// ============================================================
// كارد الفيديو
// ============================================================
class _VideoCard extends StatefulWidget {
  final VideoItem video;
  final bool isDark;
  final int delay;

  const _VideoCard({
    required this.video,
    required this.isDark,
    required this.delay,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isInitialized = false;
  bool _hasError = false;
  bool _userClickedPlay = false;

  Future<void> _initializeVideo() async {
    if (_isInitialized || _hasError) return;

    setState(() => _userClickedPlay = true);

    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        allowFullScreen: true,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'خطأ في تحميل الفيديو\n$errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          );
        },
      );

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _userClickedPlay = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoArea(),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color:
                        widget.isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                if (widget.video.description != null &&
                    widget.video.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.video.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: widget.delay.ms).slideY(begin: 0.1);
  }

  Widget _buildVideoArea() {
    if (_isInitialized &&
        _chewieController != null &&
        _videoController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    }

    if (_hasError) {
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              SizedBox(height: 8),
              Text(
                'فشل تحميل الفيديو',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_userClickedPlay) {
      return GestureDetector(
        onTap: _initializeVideo,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.video.thumbnailUrl != null &&
                widget.video.thumbnailUrl!.isNotEmpty)
              Image.network(
                widget.video.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.black87),
              )
            else
              Container(
                color: Colors.black87,
                child: const Icon(
                  Icons.movie,
                  size: 40,
                  color: Colors.white24,
                ),
              ),
            Container(color: Colors.black.withValues(alpha: 0.3)),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 36,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 8),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

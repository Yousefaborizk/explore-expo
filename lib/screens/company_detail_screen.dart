import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/company.dart';
import '../services/company_service.dart';
import '../utils/app_translations.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String slug;
  const CompanyDetailScreen({super.key, required this.slug});

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late Future<Company?> _future;

  @override
  void initState() {
    super.initState();
    _future = CompanyService.fetchBySlug(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          AppTranslations.t(context, 'company_details'),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: FutureBuilder<Company?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final company = snapshot.data;
          if (company == null) {
            return Center(
              child: Text(
                AppTranslations.t(context, 'company_not_found'),
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اللوجو
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        company.logoUrl != null && company.logoUrl!.isNotEmpty
                            ? Image.network(
                                company.logoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business,
                                  size: 60,
                                  color: Colors.black26,
                                ),
                              )
                            : const Icon(Icons.business,
                                size: 60, color: Colors.black26),
                  ),
                ).animate().fadeIn().scale(),

                const SizedBox(height: 24),

                // الاسم
                Center(
                  child: Text(
                    company.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 8),

                // Slug
                Center(
                  child: Text(
                    '/company/${company.slug}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // الوصف
                if (company.description != null &&
                    company.description!.isNotEmpty)
                  Container(
                    width: double.infinity,
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
                    child: Text(
                      company.description!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 16),

                // الموقع
                if (company.website != null && company.website!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.parse(company.website!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: Text(company.website!),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}

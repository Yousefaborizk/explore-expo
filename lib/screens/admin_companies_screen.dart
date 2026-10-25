import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/company.dart';
import '../services/company_service.dart';
import '../utils/app_translations.dart';

class AdminCompaniesScreen extends StatefulWidget {
  const AdminCompaniesScreen({super.key});

  @override
  State<AdminCompaniesScreen> createState() => _AdminCompaniesScreenState();
}

class _AdminCompaniesScreenState extends State<AdminCompaniesScreen> {
  late Future<List<Company>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = CompanyService.fetchAll();
    });
  }

  Future<void> _openEditor({Company? existing}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CompanyEditorDialog(existing: existing),
    );

    if (result == true) {
      _reload();
    }
  }

  Future<void> _confirmDelete(Company c) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.t(context, 'confirm_delete')),
        content: Text('${AppTranslations.t(context, 'delete')} "${c.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppTranslations.t(context, 'cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppTranslations.t(context, 'delete'),
              style: TextStyle(color: isDark ? Colors.white : Colors.white),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await CompanyService.delete(c.id);
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
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
          AppTranslations.t(context, 'companies'),
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: Text(AppTranslations.t(context, 'add_company')),
      ),
      body: FutureBuilder<List<Company>>(
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

          final list = snapshot.data ?? [];

          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${AppTranslations.t(context, 'companies')} — 0',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: c.logoUrl != null && c.logoUrl!.isNotEmpty
                        ? Image.network(
                            c.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business,
                              color: Colors.black26,
                            ),
                          )
                        : const Icon(Icons.business, color: Colors.black26),
                  ),
                  title: Text(
                    c.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Text(
                    '/company/${c.slug}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: AppTranslations.t(context, 'edit'),
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openEditor(existing: c),
                      ),
                      IconButton(
                        tooltip: AppTranslations.t(context, 'delete'),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(c),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// Dialog إضافة/تعديل شركة
// ============================================================
class _CompanyEditorDialog extends StatefulWidget {
  final Company? existing;

  const _CompanyEditorDialog({this.existing});

  @override
  State<_CompanyEditorDialog> createState() => _CompanyEditorDialogState();
}

class _CompanyEditorDialogState extends State<_CompanyEditorDialog> {
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _descController = TextEditingController();
  final _websiteController = TextEditingController();

  final _picker = ImagePicker();

  Uint8List? _pickedBytes;
  String? _pickedMime;
  String? _pickedName;
  String? _existingLogoUrl;

  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _nameController.text = e.name;
      _slugController.text = e.slug;
      _descController.text = e.description ?? '';
      _websiteController.text = e.website ?? '';
      _existingLogoUrl = e.logoUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _descController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  /// يولّد slug من الاسم — يدعم العربي والإنجليزي
  String _slugify(String input) {
    final trimmed = input.trim().toLowerCase();

    // استبدال المسافات بـ -
    var result = trimmed.replaceAll(RegExp(r'\s+'), '-');

    // لو الاسم عربي بحت، نحتفظ بيه (Supabase بيدعم Unicode في العمود)
    // لكن مفضل نستخدم أرقام وحروف لاتينية للـ URL
    // هنا هنسمح بحروف لاتينية وأرقام وشرطة بس
    result = result.replaceAll(RegExp(r'[^a-z0-9\-_\u0600-\u06FF]'), '');

    return result;
  }

  /// يحدد MIME type من امتداد الملف — لأن XFile.mimeType بيرجع null على الويب
  String _mimeFromName(String? name) {
    if (name == null) return 'image/png';
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.svg')) return 'image/svg+xml';
    return 'image/png';
  }

  Future<void> _pickLogo() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();

      if (!mounted) return;
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
        _pickedMime = (file.mimeType?.isNotEmpty == true)
            ? file.mimeType
            : _mimeFromName(file.name);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Image pick error: $e';
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Company name is required');
      return;
    }

    final slug = _slugController.text.trim().isEmpty
        ? _slugify(name)
        : _slugController.text.trim();

    if (slug.isEmpty) {
      setState(() => _errorMessage = 'Slug is required');
      return;
    }

    setState(() => _saving = true);

    try {
      String? logoUrl = _existingLogoUrl;

      if (_pickedBytes != null && _pickedName != null) {
        logoUrl = await CompanyService.uploadLogo(
          fileName: _pickedName!,
          bytes: _pickedBytes!,
          mimeType: _pickedMime ?? 'image/png',
        );
      }

      final desc = _descController.text.trim();
      final website = _websiteController.text.trim();

      if (widget.existing == null) {
        await CompanyService.create(
          name: name,
          slug: slug,
          description: desc.isEmpty ? null : desc,
          website: website.isEmpty ? null : website,
          logoUrl: logoUrl,
        );
      } else {
        await CompanyService.update(
          widget.existing!.id,
          name: name,
          slug: slug,
          description: desc.isEmpty ? null : desc,
          website: website.isEmpty ? null : website,
          logoUrl: logoUrl,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(
        widget.existing == null
            ? AppTranslations.t(context, 'add_company')
            : AppTranslations.t(context, 'edit'),
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== اللوجو =====
              Center(
                child: GestureDetector(
                  onTap: _saving ? null : _pickLogo,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.black.withValues(alpha: 0.1),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _pickedBytes != null
                        ? Image.memory(_pickedBytes!, fit: BoxFit.contain)
                        : (_existingLogoUrl != null &&
                                _existingLogoUrl!.isNotEmpty
                            ? Image.network(
                                _existingLogoUrl!,
                                fit: BoxFit.contain,
                              )
                            : Icon(
                                Icons.upload_file,
                                size: 40,
                                color: isDark ? Colors.white38 : Colors.black26,
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _saving ? null : _pickLogo,
                  icon: const Icon(Icons.image),
                  label: Text(AppTranslations.t(context, 'pick_logo')),
                ),
              ),

              const SizedBox(height: 16),

              // ===== اسم الشركة =====
              TextField(
                controller: _nameController,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: AppTranslations.t(context, 'company_name'),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) {
                  // لو المستخدم لسه مكتبش slug يدوي، نولّده تلقائياً
                  if (_slugController.text.isEmpty ||
                      _slugController.text == _slugify(_nameController.text)) {
                    final generated = _slugify(v);
                    _slugController.text = generated;
                  }
                },
              ),

              const SizedBox(height: 12),

              // ===== Slug =====
              TextField(
                controller: _slugController,
                enabled: !_saving,
                decoration: InputDecoration(
                  labelText: AppTranslations.t(context, 'slug'),
                  helperText: 'مثال: google → /#/company/google',
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // ===== الوصف =====
              TextField(
                controller: _descController,
                enabled: !_saving,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppTranslations.t(context, 'description'),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // ===== الموقع =====
              TextField(
                controller: _websiteController,
                enabled: !_saving,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: AppTranslations.t(context, 'website'),
                  hintText: 'https://example.com',
                  border: const OutlineInputBorder(),
                ),
              ),

              // ===== رسالة الخطأ =====
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(AppTranslations.t(context, 'cancel')),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(AppTranslations.t(context, 'save')),
        ),
      ],
    );
  }
}

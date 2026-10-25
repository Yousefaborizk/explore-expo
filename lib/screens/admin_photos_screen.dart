import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/company.dart';
import '../models/photo.dart';
import '../services/company_service.dart';
import '../services/photo_service.dart';

class AdminPhotosScreen extends StatefulWidget {
  const AdminPhotosScreen({super.key});

  @override
  State<AdminPhotosScreen> createState() => _AdminPhotosScreenState();
}

class _AdminPhotosScreenState extends State<AdminPhotosScreen> {
  late Future<List<PhotoItem>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = PhotoService.fetchAll();
    });
  }

  Future<void> _openEditor({PhotoItem? existing}) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PhotoEditorDialog(existing: existing),
    );
    if (result == true) _reload();
  }

  Future<void> _confirmDelete(PhotoItem p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('متأكد إنك عايز تحذف الصورة دي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await PhotoService.delete(p.id);
        _reload();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
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
          'إدارة الصور',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('إضافة صورة'),
      ),
      body: FutureBuilder<List<PhotoItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ: ${snapshot.error}',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            );
          }

          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد صور بعد',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اضغط الزر تحت لإضافة صورة',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 900
                  ? 4
                  : MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: photos.length,
            itemBuilder: (context, i) {
              final p = photos[i];
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            p.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 32,
                                color: isDark ? Colors.white38 : Colors.black26,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                _iconAction(
                                  icon: Icons.edit,
                                  color: Colors.blue,
                                  onTap: () => _openEditor(existing: p),
                                ),
                                const SizedBox(width: 4),
                                _iconAction(
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  onTap: () => _confirmDelete(p),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        p.title ?? 'بدون عنوان',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

// ============================================================
// Dialog إضافة/تعديل صورة
// ============================================================
class _PhotoEditorDialog extends StatefulWidget {
  final PhotoItem? existing;

  const _PhotoEditorDialog({this.existing});

  @override
  State<_PhotoEditorDialog> createState() => _PhotoEditorDialogState();
}

class _PhotoEditorDialogState extends State<_PhotoEditorDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  Uint8List? _pickedBytes;
  String? _pickedMime;
  String? _pickedName;
  String? _existingImageUrl;
  String? _selectedCompanyId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title ?? '';
      _descController.text = e.description ?? '';
      _existingImageUrl = e.imageUrl;
      _selectedCompanyId = e.companyId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _mimeFromName(String? name) {
    if (name == null) return 'image/png';
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/png';
  }

  Future<void> _pickImage() async {
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
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'خطأ في اختيار الصورة: $e');
    }
  }

  Future<void> _save() async {
    setState(() => _errorMessage = null);

    if (widget.existing == null && _pickedBytes == null) {
      setState(() => _errorMessage = 'اختر صورة أولاً');
      return;
    }

    setState(() => _saving = true);

    try {
      String imageUrl = _existingImageUrl ?? '';

      if (_pickedBytes != null && _pickedName != null) {
        imageUrl = await PhotoService.uploadImage(
          fileName: _pickedName!,
          bytes: _pickedBytes!,
          mimeType: _pickedMime ?? 'image/png',
        );
      }

      final title = _titleController.text.trim();
      final desc = _descController.text.trim();

      if (widget.existing == null) {
        await PhotoService.create(
          imageUrl: imageUrl,
          companyId: _selectedCompanyId,
          title: title.isEmpty ? null : title,
          description: desc.isEmpty ? null : desc,
        );
      } else {
        await PhotoService.update(
          widget.existing!.id,
          imageUrl: imageUrl,
          companyId: _selectedCompanyId,
          title: title.isEmpty ? null : title,
          description: desc.isEmpty ? null : desc,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(widget.existing == null ? 'إضافة صورة' : 'تعديل صورة'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ===== اختيار الصورة =====
              GestureDetector(
                onTap: _saving ? null : _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedBytes != null
                      ? Image.memory(_pickedBytes!, fit: BoxFit.cover)
                      : (_existingImageUrl != null &&
                              _existingImageUrl!.isNotEmpty
                          ? Image.network(
                              _existingImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    size: 40,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black26,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'اختر صورة من الجهاز',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _saving ? null : _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('تغيير الصورة'),
              ),

              const SizedBox(height: 12),

              // ===== العنوان =====
              TextField(
                controller: _titleController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'العنوان (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // ===== الوصف =====
              TextField(
                controller: _descController,
                enabled: !_saving,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // ===== ربط بشركة (اختياري) =====
              FutureBuilder<List<Company>>(
                future: CompanyService.fetchAll(),
                builder: (context, snapshot) {
                  final companies = snapshot.data ?? [];
                  return DropdownButtonFormField<String>(
                    key: ValueKey(_selectedCompanyId),
                    initialValue: _selectedCompanyId,
                    decoration: const InputDecoration(
                      labelText: 'ربط بشركة (اختياري)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('بدون شركة'),
                      ),
                      ...companies.map(
                        (c) => DropdownMenuItem<String>(
                          value: c.id,
                          child: Text('#${c.serialNumber} — ${c.name}'),
                        ),
                      ),
                    ],
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _selectedCompanyId = v),
                  );
                },
              ),

              // ===== رسالة خطأ =====
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

              // ===== تحميل =====
              if (_saving) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                const Text(
                  'جاري الرفع...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}

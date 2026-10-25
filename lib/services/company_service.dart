import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company.dart';

class CompanyService {
  static final _client = Supabase.instance.client;

  /// جلب كل الشركات مرتبة بالرقم التسلسلي
  static Future<List<Company>> fetchAll() async {
    final data = await _client
        .from('companies')
        .select()
        .order('serial_number', ascending: true);
    return data.map<Company>((e) => Company.fromMap(e)).toList();
  }

  /// جلب شركة بالرقم التسلسلي (الرقم اللي في الـ URL)
  static Future<Company?> fetchBySerial(int serial) async {
    final data = await _client
        .from('companies')
        .select()
        .eq('serial_number', serial)
        .maybeSingle();
    if (data == null) return null;
    return Company.fromMap(data);
  }

  /// جلب شركة بالـ slug
  static Future<Company?> fetchBySlug(String slug) async {
    final data =
        await _client.from('companies').select().eq('slug', slug).maybeSingle();
    if (data == null) return null;
    return Company.fromMap(data);
  }

  /// إضافة شركة جديدة
  static Future<void> create({
    required String name,
    required String slug,
    String? description,
    String? website,
    String? logoUrl,
  }) async {
    await _client.from('companies').insert({
      'name': name,
      'slug': slug,
      'description': description,
      'website': website,
      'logo_url': logoUrl,
    });
  }

  /// تعديل شركة موجودة
  static Future<void> update(
    String id, {
    required String name,
    required String slug,
    String? description,
    String? website,
    String? logoUrl,
  }) async {
    await _client.from('companies').update({
      'name': name,
      'slug': slug,
      'description': description,
      'website': website,
      'logo_url': logoUrl,
    }).eq('id', id);
  }

  /// حذف شركة
  static Future<void> delete(String id) async {
    await _client.from('companies').delete().eq('id', id);
  }

  /// رفع لوجو وإرجاع الـ Public URL
  static Future<String> uploadLogo({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('company-logos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType),
        );
    return _client.storage.from('company-logos').getPublicUrl(path);
  }
}

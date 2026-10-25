import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/photo.dart';

class PhotoService {
  static final _client = Supabase.instance.client;

  /// جلب كل الصور (الأحدث أولاً)
  static Future<List<PhotoItem>> fetchAll() async {
    final data = await _client
        .from('photos')
        .select()
        .order('created_at', ascending: false);
    return data.map<PhotoItem>((e) => PhotoItem.fromMap(e)).toList();
  }

  /// جلب صور شركة معينة
  static Future<List<PhotoItem>> fetchByCompany(String companyId) async {
    final data = await _client
        .from('photos')
        .select()
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return data.map<PhotoItem>((e) => PhotoItem.fromMap(e)).toList();
  }

  /// إضافة صورة
  static Future<void> create({
    required String imageUrl,
    String? companyId,
    String? title,
    String? description,
  }) async {
    await _client.from('photos').insert({
      'image_url': imageUrl,
      'company_id': companyId,
      'title': title,
      'description': description,
    });
  }

  /// تعديل صورة
  static Future<void> update(
    String id, {
    required String imageUrl,
    String? companyId,
    String? title,
    String? description,
  }) async {
    await _client.from('photos').update({
      'image_url': imageUrl,
      'company_id': companyId,
      'title': title,
      'description': description,
    }).eq('id', id);
  }

  /// حذف صورة
  static Future<void> delete(String id) async {
    await _client.from('photos').delete().eq('id', id);
  }

  /// رفع صورة وإرجاع الـ Public URL
  static Future<String> uploadImage({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('photos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType),
        );
    return _client.storage.from('photos').getPublicUrl(path);
  }
}

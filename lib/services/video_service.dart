import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/video.dart';

class VideoService {
  static final _client = Supabase.instance.client;

  static Future<List<VideoItem>> fetchAll() async {
    final data = await _client
        .from('videos')
        .select()
        .order('created_at', ascending: false);
    return data.map<VideoItem>((e) => VideoItem.fromMap(e)).toList();
  }

  static Future<List<VideoItem>> fetchByCompany(String companyId) async {
    final data = await _client
        .from('videos')
        .select()
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
    return data.map<VideoItem>((e) => VideoItem.fromMap(e)).toList();
  }

  static Future<void> create({
    required String title,
    required String videoUrl,
    String? companyId,
    String? thumbnailUrl,
    String? description,
  }) async {
    await _client.from('videos').insert({
      'title': title,
      'video_url': videoUrl,
      'company_id': companyId,
      'thumbnail_url': thumbnailUrl,
      'description': description,
    });
  }

  static Future<void> update(
    String id, {
    required String title,
    required String videoUrl,
    String? companyId,
    String? thumbnailUrl,
    String? description,
  }) async {
    await _client.from('videos').update({
      'title': title,
      'video_url': videoUrl,
      'company_id': companyId,
      'thumbnail_url': thumbnailUrl,
      'description': description,
    }).eq('id', id);
  }

  static Future<void> delete(String id) async {
    await _client.from('videos').delete().eq('id', id);
  }

  static Future<String> uploadVideo({
    required String fileName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('videos').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType),
        );
    return _client.storage.from('videos').getPublicUrl(path);
  }
}

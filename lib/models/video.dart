class VideoItem {
  final String id;
  final String? companyId;
  final String title;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? description;
  final DateTime createdAt;

  VideoItem({
    required this.id,
    this.companyId,
    required this.title,
    required this.videoUrl,
    this.thumbnailUrl,
    this.description,
    required this.createdAt,
  });

  factory VideoItem.fromMap(Map<String, dynamic> map) {
    return VideoItem(
      id: map['id'],
      companyId: map['company_id'],
      title: map['title'] ?? '',
      videoUrl: map['video_url'] ?? '',
      thumbnailUrl: map['thumbnail_url'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

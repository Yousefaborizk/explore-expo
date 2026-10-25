class PhotoItem {
  final String id;
  final String? companyId;
  final String? title;
  final String imageUrl;
  final String? description;
  final DateTime createdAt;

  PhotoItem({
    required this.id,
    this.companyId,
    this.title,
    required this.imageUrl,
    this.description,
    required this.createdAt,
  });

  factory PhotoItem.fromMap(Map<String, dynamic> map) {
    return PhotoItem(
      id: map['id'],
      companyId: map['company_id'],
      title: map['title'],
      imageUrl: map['image_url'] ?? '',
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

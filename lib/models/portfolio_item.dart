class PortfolioItem {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  PortfolioItem({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

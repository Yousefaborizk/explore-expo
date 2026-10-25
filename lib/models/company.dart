class Company {
  final String id;
  final int? serialNumber;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? description;
  final String? website;
  final DateTime createdAt;

  Company({
    required this.id,
    this.serialNumber,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.description,
    this.website,
    required this.createdAt,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'],
      serialNumber: map['serial_number'] is int
          ? map['serial_number']
          : int.tryParse('${map['serial_number']}'),
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      logoUrl: map['logo_url'],
      description: map['description'],
      website: map['website'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

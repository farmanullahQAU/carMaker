class CardTemplate {
  final String id;
  final String name;
  final String? thumbnailPath;
  final String backgroundImage;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Category info
  final String category; // e.g. "Birthday"
  final String categoryId; // e.g. "birthday"

  /// Design compatibility
  final List<String> compatibleDesigns;

  /// Template dimensions
  final double width;
  final double height;

  /// Optional extras
  final bool isPremium;
  final List<String> tags;

  CardTemplate({
    required this.id,
    required this.name,
    this.thumbnailPath,
    required this.backgroundImage,
    required this.items,
    DateTime? createdAt,
    this.updatedAt,
    this.category = 'general',
    required this.categoryId,
    this.compatibleDesigns = const [],
    this.width = 1240,
    this.height = 1740,
    this.isPremium = false,
    this.tags = const [],
    required String imagePath,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CardTemplate.fromJson(Map<String, dynamic> json) => CardTemplate(
    imagePath: "assets/card1.png",
    id: json['id'],
    name: json['name'],
    thumbnailPath: json['thumbnailPath'],
    backgroundImage: json['backgroundImage'],
    items: List<Map<String, dynamic>>.from(json['items']),
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    updatedAt: json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'])
        : null,
    category: json['category'] ?? 'general',
    categoryId: json['categoryId'] ?? 'general',
    compatibleDesigns: List<String>.from(json['compatibleDesigns'] ?? []),
    width: (json['width'] ?? 1000).toDouble(),
    height: (json['height'] ?? 1000).toDouble(),
    isPremium: json['isPremium'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (thumbnailPath != null) 'thumbnailPath': thumbnailPath,
    'backgroundImage': backgroundImage,
    'items': items,
    'createdAt': createdAt.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    'category': category,
    'categoryId': categoryId,
    'compatibleDesigns': compatibleDesigns,
    'width': width,
    'height': height,
    'isPremium': isPremium,
    'tags': tags,
  };

  double get aspectRatio => width / height;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CardTemplate {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final String? backgroundImageUrl;
  final List<Map<String, dynamic>> items;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String category;
  final String categoryId;
  final bool isFeatured;
  final List<String> compatibleDesigns;
  final double width;
  final double height;
  final bool isPremium;
  final List<String> tags;
  final IconData? icon;
  final Color color;

  CardTemplate({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    this.backgroundImageUrl,
    required this.items,
    DateTime? createdAt,
    this.updatedAt,
    this.category = 'general',
    required this.categoryId,
    this.isFeatured = false,
    this.compatibleDesigns = const [],
    this.width = 1240,
    this.height = 1740,
    this.isPremium = false,
    this.tags = const [],
    required String imagePath,
    this.icon,
    this.color = Colors.transparent,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CardTemplate.fromJson(Map<String, dynamic> json) => CardTemplate(
    imagePath: json['imagePath'] ?? "assets/card1.png",
    id: json['id'],
    name: json['name'],
    thumbnailUrl: json['thumbnailUrl'],
    backgroundImageUrl: json['backgroundImageUrl'],
    items: List<Map<String, dynamic>>.from(json['items']),
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] as Timestamp).toDate()
        : null,
    updatedAt: json['updatedAt'] != null
        ? (json['updatedAt'] as Timestamp).toDate()
        : null,
    category: json['category'] ?? 'general',
    categoryId: json['categoryId'] ?? 'general',
    isFeatured: json['isFeatured'] ?? false,
    compatibleDesigns: List<String>.from(json['compatibleDesigns'] ?? []),
    width: (json['width'] ?? 1000).toDouble(),
    height: (json['height'] ?? 1000).toDouble(),
    isPremium: json['isPremium'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
    icon: IconData(
      json['icon'] ?? Icons.image.codePoint,
      fontFamily: 'MaterialIcons',
    ),
    color: Color(json['color'] ?? 0xFF000000),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    'backgroundImageUrl': backgroundImageUrl,
    'items': items,
    'createdAt': FieldValue.serverTimestamp(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    'category': category,
    'categoryId': categoryId,
    'isFeatured': isFeatured,
    'compatibleDesigns': compatibleDesigns,
    'width': width,
    'height': height,
    'isPremium': isPremium,
    'tags': tags,
    'icon': icon?.codePoint,
    'color': color.toARGB32(),
  };

  double get aspectRatio => width / height;
}

class CategoryModel {
  final String id;
  final String name;
  final Color color;
  final IconData icon;
  final String? imagePath;

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'icon': icon.codePoint,
    'imagePath': imagePath,
  };

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    color: Color(json['color']),
    icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
    imagePath: json['imagePath'],
  );
}

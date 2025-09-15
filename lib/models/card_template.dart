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
  final String imagePath;
  final IconData? icon;
  final Color color;
  final double? backgroundHue;

  final bool isDraft;

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
    required this.imagePath,
    this.icon,
    this.color = Colors.transparent,
    this.backgroundHue = 0.0,
    this.isDraft = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CardTemplate.fromJson(Map<String, dynamic> json) => CardTemplate(
    imagePath: json['imagePath'] ?? "assets/card1.png",
    id: json['id'],
    name: json['name'],
    thumbnailUrl: json['thumbnailUrl'],
    backgroundImageUrl: json['backgroundImageUrl'],
    items: List<Map<String, dynamic>>.from(json['items'] ?? []),
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt']))
        : null,
    updatedAt: json['updatedAt'] != null
        ? (json['updatedAt'] is Timestamp
              ? (json['updatedAt'] as Timestamp).toDate()
              : DateTime.parse(json['updatedAt']))
        : null,
    category: json['category'] ?? 'general',
    categoryId: json['categoryId'] ?? 'general',
    isFeatured: json['isFeatured'] ?? false,
    compatibleDesigns: List<String>.from(json['compatibleDesigns'] ?? []),
    width: (json['width'] is double
        ? json['width']
        : (json['width'] ?? 1000).toDouble()),
    height: (json['height'] is double
        ? json['height']
        : (json['height'] ?? 1000).toDouble()),
    isPremium: json['isPremium'] ?? false,
    tags: List<String>.from(json['tags'] ?? []),
    icon: json['icon'] != null
        ? IconData(
            json['icon'] is int ? json['icon'] : Icons.image.codePoint,
            fontFamily: 'MaterialIcons',
          )
        : null,

    backgroundHue: json['backgroundHue'].toDouble(),
    isDraft: json['isDraft'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    if (backgroundImageUrl != null) 'backgroundImageUrl': backgroundImageUrl,
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
    'imagePath': imagePath,
    if (icon != null) 'icon': icon!.codePoint,
    'backgroundHue': backgroundHue,
    'isDraft': isDraft,
  };

  double get aspectRatio => width / height;

  CardTemplate copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    String? backgroundImageUrl,
    double? backgroundHue,
    List<Map<String, dynamic>>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? categoryId,
    bool? isFeatured,
    List<String>? compatibleDesigns,
    double? width,
    double? height,
    bool? isPremium,
    List<String>? tags,
    String? imagePath,
    IconData? icon,
    bool? isDraft,
  }) {
    return CardTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      backgroundHue: backgroundHue ?? this.backgroundHue,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      isFeatured: isFeatured ?? this.isFeatured,
      compatibleDesigns: compatibleDesigns ?? this.compatibleDesigns,
      width: width ?? this.width,
      height: height ?? this.height,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
      imagePath: imagePath ?? this.imagePath,
      icon: icon ?? this.icon,

      isDraft: isDraft ?? this.isDraft,
    );
  }
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

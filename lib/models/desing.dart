import 'package:flutter/material.dart';

class CategoryModel {
  final String id; // e.g., "birthday", "wedding"
  final String name; // Display title
  final String? imagePath; // Optional background or icon image
  final IconData? icon; // Optional icon for display
  final Color color; // For UI use
  final bool isPremium;
  final bool isPopular;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.imagePath,
    this.icon,
    this.color = Colors.grey,
    this.isPremium = false,
    this.isPopular = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'],
    name: json['name'],
    imagePath: json['imagePath'],
    isPremium: json['isPremium'] ?? false,
    icon: null, // can't deserialize IconData, handle separately in UI
    color: Colors.grey, // assign via logic in app
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : DateTime.now(),
    isPopular: json['isPopular'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imagePath': imagePath,
    'isPremium': isPremium,
    'createdAt': createdAt.toIso8601String(),
    'isPopular': isPopular,
  };
}

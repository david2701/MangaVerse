// lib/models/category.dart
import 'dart:io';

class Category {
  final String id;
  final String name;
  final File coverImage;

  Category({
    required this.id,
    required this.name,
    required this.coverImage,
  });

  Category copyWith({
    String? id,
    String? name,
    File? coverImage,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
    );
  }

  // Método para convertir Category a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coverImagePath': coverImage.path,
    };
  }

  // Método para crear Category desde Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      coverImage: File(map['coverImagePath']),
    );
  }
}
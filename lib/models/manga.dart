// lib/models/manga.dart

import 'dart:io';

class Manga {
  final String id;
  final String title;
  final String filePath;
  final File coverImage;
  final String categoryId;
  final int lastPage;
  final bool isFavorite;
  final bool isReading;
  final bool isFinished;

  Manga({
    required this.id,
    required this.title,
    required this.filePath,
    required this.coverImage,
    required this.categoryId,
    this.lastPage = 1,
    this.isFavorite = false,
    this.isReading = false, // Cambiado a false
    this.isFinished = false,
  });

  factory Manga.fromMap(Map<String, dynamic> map) {
    return Manga(
      id: map['id'],
      title: map['title'],
      filePath: map['filePath'],
      coverImage: File(map['coverImage']),
      categoryId: map['categoryId'],
      lastPage: map['lastPage'],
      isFavorite: map['isFavorite'],
      isReading: map['isReading'],
      isFinished: map['isFinished'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'coverImage': coverImage.path,
      'categoryId': categoryId,
      'lastPage': lastPage,
      'isFavorite': isFavorite,
      'isReading': isReading,
      'isFinished': isFinished,
    };
  }
}
// lib/providers/manga_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../models/manga.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter/material.dart';

class MangaNotifier extends StateNotifier<List<Manga>> {
  MangaNotifier() : super([]) {
    loadMangas();
  }

  /// Carga los mangas almacenados en SharedPreferences.
  Future<void> loadMangas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mangasData = prefs.getStringList('mangas') ?? [];
      state = mangasData.map((mangaString) {
        final Map<String, dynamic> mangaMap = json.decode(mangaString);
        return Manga.fromMap(mangaMap);
      }).toList();
      print('Mangas cargados exitosamente. Total: ${state.length}');
    } catch (e) {
      print('Error al cargar mangas: $e');
    }
  }

  /// Guarda los mangas actuales en SharedPreferences.
  Future<void> saveMangas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mangasData = state.map((manga) => json.encode(manga.toMap())).toList();
      await prefs.setStringList('mangas', mangasData);
      print('Mangas guardados exitosamente.');
    } catch (e) {
      print('Error al guardar mangas: $e');
    }
  }

  /// Importa mangas desde un directorio específico.
  Future<List<Manga>> importMangasFromDirectory({
    required String directoryPath,
    required String categoryId,
    required String Function(String originalName) nameGenerator,
    bool deleteOriginal = false,
  }) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      throw Exception("El directorio no existe: $directoryPath");
    }

    List<Manga> importedMangas = [];

    try {
      // Listar de manera asíncrona y recursiva
      final List<FileSystemEntity> allEntities = await directory.list(recursive: true).toList();
      print('Contenido del directorio $directoryPath:');
      for (var entity in allEntities) {
        print(entity.path);
      }

      // Filtrar solo archivos PDF
      final pdfFiles = allEntities.where((entity) =>
      entity is File && p.extension(entity.path).toLowerCase() == '.pdf').cast<File>().toList();

      if (pdfFiles.isEmpty) {
        throw Exception("No se encontraron archivos PDF en el directorio seleccionado.");
      }

      print('Archivos PDF encontrados: ${pdfFiles.length}');

      // Obtener el directorio interno de la app para almacenar los PDFs
      final appDir = await getApplicationDocumentsDirectory();
      final mangasDir = Directory(p.join(appDir.path, 'mangas'));
      if (!await mangasDir.exists()) {
        await mangasDir.create(recursive: true);
        print('Directorio de mangas creado en: ${mangasDir.path}');
      }

      for (final pdf in pdfFiles) {
        try {
          // Generar un nuevo nombre para el archivo PDF
          final originalName = p.basenameWithoutExtension(pdf.path);
          final newFileName = nameGenerator(originalName);
          final newFilePath = p.join(mangasDir.path, '$newFileName.pdf');

          // Copiar el archivo PDF al almacenamiento interno
          final copiedPdf = await pdf.copy(newFilePath);
          print('Archivo copiado a: ${copiedPdf.path}');

          // Generar una portada desde la primera página del PDF
          final coverFromPdf = await _generateCoverFromPdf(copiedPdf);
          print('Portada generada en: ${coverFromPdf.path}');

          // Crear una instancia de Manga
          final manga = Manga(
            id: UniqueKey().toString(),
            title: newFileName,
            filePath: copiedPdf.path,
            coverImage: coverFromPdf, // Asignar el File generado
            categoryId: categoryId,
            lastPage: 1,
            isFavorite: false,
            isReading: false, // Asegurar que sea false por defecto
            isFinished: false,
          );

          // Agregar el manga al estado
          addManga(manga);
          importedMangas.add(manga);

          // (Opcional) Eliminar el archivo original
          if (deleteOriginal) {
            await pdf.delete();
            print('Archivo original eliminado: ${pdf.path}');
          }
        } catch (e) {
          // Manejar errores individualmente para cada archivo
          print('Error al importar ${pdf.path}: $e');
        }
      }

      // Guardar el estado actualizado
      await saveMangas();
      print('Importación de mangas completada.');

      return importedMangas;
    } catch (e) {
      print('Error al importar mangas desde el directorio: $e');
      throw Exception("Error al importar mangas desde el directorio: $e");
    }
  }

  /// Genera una portada extrayendo la primera página del PDF.
  Future<File> _generateCoverFromPdf(File pdfFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(appDir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
        print('Directorio de covers creado en: ${coversDir.path}');
      }

      final coverFileName = '${p.basenameWithoutExtension(pdfFile.path)}_cover.png';
      final coverFile = File(p.join(coversDir.path, coverFileName));

      if (!await coverFile.exists()) {
        // Abrir el documento PDF
        final doc = await PdfDocument.openFile(pdfFile.path);
        // Obtener la primera página
        final page = await doc.getPage(1);
        // Renderizar la página como imagen PNG
        final pageImage = await page.render(
          width: page.width,
          height: page.height,
          format: PdfPageImageFormat.png,
        );
        // Escribir los bytes de la imagen en el archivo de portada
        await coverFile.writeAsBytes(pageImage!.bytes);
        await page.close();
        await doc.close();
        print('Portada generada desde PDF en: ${coverFile.path}');
      } else {
        print('Portada existente encontrada en: ${coverFile.path}');
      }

      return coverFile;
    } catch (e) {
      print('Error al generar la portada desde PDF: $e');
      // En caso de error, retorna una portada por defecto
      return await _generateDefaultCoverFallback(pdfFile);
    }
  }

  /// Función auxiliar para generar una portada por defecto en caso de error.
  Future<File> _generateDefaultCoverFallback(File pdfFile) async {
    try {
      // Ruta de la imagen de portada por defecto en assets
      final defaultCoverPath = 'assets/default_cover.png';

      // Obtener el directorio interno para almacenar las portadas
      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory(p.join(appDir.path, 'covers'));
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
        print('Directorio de covers creado en: ${coversDir.path}');
      }

      // Definir la ruta del archivo de portada
      final coverFileName = '${p.basenameWithoutExtension(pdfFile.path)}_default_cover.png';
      final coverFile = File(p.join(coversDir.path, coverFileName));

      if (!await coverFile.exists()) {
        // Leer la imagen de assets
        final byteData = await rootBundle.load(defaultCoverPath);
        await coverFile.writeAsBytes(byteData.buffer.asUint8List());
        print('Portada por defecto copiada a: ${coverFile.path}');
      } else {
        print('Portada por defecto existente encontrada en: ${coverFile.path}');
      }

      return coverFile;
    } catch (e) {
      print('Error al generar la portada por defecto: $e');
      // En caso de error, retorna un archivo vacío o maneja según tu lógica
      return File('');
    }
  }

  /// Función auxiliar para generar una portada por defecto (mantener la original).
  Future<File> _generateDefaultCover(File pdfFile) async {
    // Puedes mantener esta función o eliminarla si ya no es necesaria
    return await _generateDefaultCoverFallback(pdfFile);
  }

  /// Agrega un nuevo manga al estado y guarda los cambios.
  void addManga(Manga manga) {
    state = [...state, manga];
    saveMangas();
    print('Manga agregado: ${manga.title}');
  }

  /// Actualiza el estado de un manga específico.
  void updateMangaStatus(Manga manga, {bool? isFavorite, bool? isReading, bool? isFinished}) {
    state = state.map((m) {
      if (m.id == manga.id) {
        return Manga(
          id: m.id,
          title: m.title,
          filePath: m.filePath,
          coverImage: m.coverImage,
          categoryId: m.categoryId,
          lastPage: m.lastPage,
          isFavorite: isFavorite ?? m.isFavorite,
          isReading: isReading ?? m.isReading,
          isFinished: isFinished ?? m.isFinished,
        );
      }
      return m;
    }).toList();
    saveMangas();
    print('Estado de manga actualizado: ${manga.title}');
  }

  /// Actualiza la última página leída de un manga específico.
  void updateLastPage(Manga manga, int page) {
    state = state.map((m) {
      if (m.id == manga.id) {
        return Manga(
          id: m.id,
          title: m.title,
          filePath: m.filePath,
          coverImage: m.coverImage,
          categoryId: m.categoryId,
          lastPage: page,
          isFavorite: m.isFavorite,
          isReading: m.isReading,
          isFinished: m.isFinished,
        );
      }
      return m;
    }).toList();
    saveMangas();
    print('Última página actualizada para: ${manga.title} a la página $page');
  }

  /// Actualiza el título de un manga específico.
  void updateMangaTitle(Manga manga, String newTitle) {
    state = state.map((m) {
      if (m.id == manga.id) {
        return Manga(
          id: m.id,
          title: newTitle,
          filePath: m.filePath,
          coverImage: m.coverImage,
          categoryId: m.categoryId,
          lastPage: m.lastPage,
          isFavorite: m.isFavorite,
          isReading: m.isReading,
          isFinished: m.isFinished,
        );
      }
      return m;
    }).toList();
    saveMangas();
    print('Título de manga actualizado: $newTitle');
  }

  /// Elimina un manga del estado y del almacenamiento interno.
  Future<void> deleteManga(Manga manga) async {
    try {
      // Eliminar archivo PDF
      final pdfFile = File(manga.filePath);
      if (await pdfFile.exists()) {
        await pdfFile.delete();
        print('Archivo PDF eliminado: ${pdfFile.path}');
      }

      // Eliminar archivo de portada
      final coverFile = manga.coverImage;
      if (await coverFile.exists()) {
        await coverFile.delete();
        print('Archivo de portada eliminado: ${coverFile.path}');
      }

      // Actualizar el estado
      state = state.where((m) => m.id != manga.id).toList();
      await saveMangas();
      print('Manga eliminado: ${manga.title}');
    } catch (e) {
      print('Error al eliminar el manga: $e');
    }
  }

// Implementar otras funciones según sea necesario...
}

final mangaProvider = StateNotifierProvider<MangaNotifier, List<Manga>>((ref) {
  return MangaNotifier();
});

// Providers para filtros
final favoritesProvider = Provider<List<Manga>>((ref) {
  return ref.watch(mangaProvider).where((manga) => manga.isFavorite).toList();
});

final readingProvider = Provider<List<Manga>>((ref) {
  return ref.watch(mangaProvider).where((manga) => manga.isReading).toList();
});

final finishedProvider = Provider<List<Manga>>((ref) {
  return ref.watch(mangaProvider).where((manga) => manga.isFinished).toList();
});
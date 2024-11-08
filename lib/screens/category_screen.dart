import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/manga.dart';
import '../providers/category_provider.dart';
import '../providers/manga_provider.dart';

class CategoryScreen extends ConsumerWidget {
  final Category category;

  const CategoryScreen({required this.category});

  Future<File?> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar la imagen'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }

  void _showEditCategory(BuildContext context) {
    final nameController = TextEditingController(text: category.name);
    File? newCoverImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Editar Categoría',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16),
                // Campo para la imagen
                GestureDetector(
                  onTap: () async {
                    final File? image = await _pickImage(context);
                    if (image != null) {
                      setState(() {
                        newCoverImage = image;
                      });
                    }
                  },
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: newCoverImage != null
                              ? Image.file(
                            newCoverImage!,
                            fit: BoxFit.cover,
                          )
                              : Image.file(
                            category.coverImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Cambiar imagen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Campo para el nombre
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    filled: true,
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    SizedBox(width: 8),
                    Consumer(
                      builder: (context, ref, child) => ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          if (newName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('El nombre no puede estar vacío'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          await ref.read(categoryProvider.notifier).updateCategory(
                            category.id,
                            name: newName,
                            coverImage: newCoverImage,
                          );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Categoría actualizada'),
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save, size: 18),
                            SizedBox(width: 8),
                            Text('Guardar'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sort_by_alpha),
              title: Text('Título'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Fecha de adición'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Última lectura'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangas = ref.watch(mangaProvider)
        .where((manga) => manga.categoryId == category.id)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de la categoría
                  Image.file(
                    category.coverImage,
                    fit: BoxFit.cover,
                  ),
                  // Gradiente para mejorar legibilidad
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                category.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              centerTitle: true,
              collapseMode: CollapseMode.pin,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.sort, size: 22, color: Colors.white,),
                onPressed: () => _showSortOptions(context),
                tooltip: 'Ordenar',
              ),
              IconButton(
                icon: Icon(Icons.edit, size: 22, color: Colors.white,),
                onPressed: () => _showEditCategory(context),
                tooltip: 'Editar categoría',
              ),
            ],
          ),

          // Contador de mangas
          SliverPadding(
            padding: EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${mangas.length} manga${mangas.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Grid de mangas
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            sliver: mangas.isEmpty
                ? SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.collections_bookmark_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay mangas en esta categoría',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                MediaQuery.of(context).size.width > 600 ? 4 : 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return MangaCard(manga: mangas[index]);
                },
                childCount: mangas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MangaCard extends ConsumerWidget {
  final Manga manga;

  const MangaCard({required this.manga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/viewer', arguments: manga),
      onLongPress: () => _showOptionsSheet(context, ref),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen de portada
              Image.file(
                manga.coverImage,
                fit: BoxFit.cover,
              ),

              // Degradado sutil
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),

              // Título
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Indicadores de estado
              Positioned(
                top: 4,
                right: 4,
                child: Column(
                  children: [
                    if (manga.isFavorite)
                      _buildStateIndicator(
                        Icons.favorite_rounded,
                        Colors.red.withOpacity(0.9),
                      ),
                    if (manga.isReading)
                      _buildStateIndicator(
                        Icons.book_rounded,
                        Colors.blue.withOpacity(0.9),
                      ),
                    if (manga.isFinished)
                      _buildStateIndicator(
                        Icons.check_circle_rounded,
                        Colors.green.withOpacity(0.9),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateIndicator(IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(manga.isFavorite ? Icons.favorite : Icons.favorite_border),
              title: Text('Favorito'),
              onTap: () {
                ref.read(mangaProvider.notifier).updateMangaStatus(
                  manga,
                  isFavorite: !manga.isFavorite,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(manga.isReading ? Icons.book : Icons.book_outlined),
              title: Text('En Lectura'),
              onTap: () {
                ref.read(mangaProvider.notifier).updateMangaStatus(
                  manga,
                  isReading: !manga.isReading,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                manga.isFinished ? Icons.check_circle : Icons.check_circle_outline,
              ),
              title: Text('Completado'),
              onTap: () {
                ref.read(mangaProvider.notifier).updateMangaStatus(
                  manga,
                  isFinished: !manga.isFinished,
                );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Renombrar'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(context, ref);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Eliminar de la categoría'),
              onTap: () {
                // Implementar lógica para eliminar de la categoría
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: manga.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Renombrar'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Título',
            border: OutlineInputBorder(),
            filled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty && newTitle != manga.title) {
                ref.read(mangaProvider.notifier).updateMangaTitle(manga, newTitle);
              }
              Navigator.pop(context);
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
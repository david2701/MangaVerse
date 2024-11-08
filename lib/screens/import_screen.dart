// lib/screens/import_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/manga.dart';
import '../providers/category_provider.dart';
import '../providers/manga_provider.dart';
import '../models/category.dart'; // Importar el modelo Category
import 'dart:io';

class ImportScreen extends ConsumerStatefulWidget {
  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  String? selectedCategoryId;
  bool deleteOriginal = false;
  bool isImporting = false;

  /// Solicita permisos de almacenamiento completo al usuario.
  Future<bool> _requestManageExternalStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
      if (status.isDenied) {
        // Mostrar un diálogo explicando por qué se necesita el permiso
        bool openSettings = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permiso Necesario'),
            content: Text('Esta aplicación necesita acceso completo al almacenamiento para importar mangas.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Configuración'),
              ),
            ],
          ),
        );
        if (openSettings) {
          await openAppSettings();
        }
      }
    }
    if (await Permission.manageExternalStorage.isGranted) {
      print('Permiso de almacenamiento completo concedido.');
      return true;
    } else {
      print('Permiso de almacenamiento completo denegado.');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Importar Mangas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Seleccionar Categoría
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Seleccionar Categoría'),
              items: categories.map<DropdownMenuItem<String>>((Category category) {
                return DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
              validator: (value) => value == null ? 'Seleccione una categoría' : null,
            ),
            SizedBox(height: 20),

            // Opción para eliminar archivos originales
            SwitchListTile(
              title: Text('Eliminar archivos originales después de importar'),
              value: deleteOriginal,
              onChanged: (val) {
                setState(() {
                  deleteOriginal = val;
                });
              },
            ),
            SizedBox(height: 20),

            // Botón para seleccionar directorio e importar
            ElevatedButton.icon(
              icon: Icon(Icons.folder_open),
              label: Text('Seleccionar Directorio e Importar'),
              onPressed: isImporting
                  ? null
                  : () async {
                if (selectedCategoryId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccione una categoría primero.')),
                  );
                  return;
                }

                // Solicitar permisos de almacenamiento completo
                bool hasPermission = await _requestManageExternalStoragePermission();
                if (!hasPermission) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Permiso de almacenamiento denegado.')),
                  );
                  return;
                }

                // Seleccionar directorio
                String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                if (selectedDirectory == null) {
                  // El usuario canceló la selección
                  return;
                }

                setState(() {
                  isImporting = true;
                });

                try {
                  List<Manga> importedMangas = await ref.read(mangaProvider.notifier).importMangasFromDirectory(
                    directoryPath: selectedDirectory,
                    categoryId: selectedCategoryId!,
                    nameGenerator: (originalName) => originalName.trim(), // Puedes personalizar esta lógica
                    deleteOriginal: deleteOriginal,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${importedMangas.length} mangas importados exitosamente.')),
                  );

                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al importar mangas: $e')),
                  );
                } finally {
                  setState(() {
                    isImporting = false;
                  });
                }
              },
            ),
            if (isImporting)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
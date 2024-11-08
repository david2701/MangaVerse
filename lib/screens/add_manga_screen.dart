// add_manga_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/manga.dart';
import '../providers/category_provider.dart';
import '../providers/manga_provider.dart';

class AddMangaScreen extends ConsumerStatefulWidget {
  @override
  _AddMangaScreenState createState() => _AddMangaScreenState();
}

class _AddMangaScreenState extends ConsumerState<AddMangaScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  File? pdfFile;
  File? coverImage;
  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Manga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedFile = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                  if (pickedFile != null) {
                    setState(() {
                      pdfFile = File(pickedFile.files.single.path!);
                    });
                  }
                },
                child: Container(
                  height: 50,
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(pdfFile == null ? 'Seleccionar PDF' : pdfFile!.path.split('/').last),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      coverImage = File(pickedFile.path);
                    });
                  }
                },
                child: coverImage == null
                    ? Container(
                  width: 100,
                  height: 150,
                  color: Colors.grey[300],
                  child: Icon(Icons.add_a_photo),
                )
                    : Image.file(coverImage!, width: 100, height: 150, fit: BoxFit.cover),
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Título del Manga'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un título' : null,
                onSaved: (value) => title = value!,
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Categoría'),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCategoryId = val;
                  });
                },
                validator: (value) => value == null ? 'Seleccione una categoría' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Añadir Manga'),
                onPressed: () {
                  if (_formKey.currentState!.validate() && pdfFile != null && coverImage != null) {
                    _formKey.currentState!.save();
                    ref.read(mangaProvider.notifier).addManga(
                      Manga(
                        id: UniqueKey().toString(),
                        title: title,
                        filePath: pdfFile!.path,
                        coverImage: coverImage!,
                        categoryId: selectedCategoryId!,
                        lastPage: 1,
                        isFavorite: false,
                        isReading: true,
                        isFinished: false,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Complete todos los campos')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
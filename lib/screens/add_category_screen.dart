// add_category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/category.dart';
import '../providers/category_provider.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  String categoryName = '';
  File? coverImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Añadir Categoría'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                  height: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.add_a_photo),
                )
                    : Image.file(coverImage!, width: 100, height: 100, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
                validator: (value) => value == null || value.isEmpty ? 'Ingrese un nombre' : null,
                onSaved: (value) => categoryName = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Crear Categoría'),
                onPressed: () {
                  if (_formKey.currentState!.validate() && coverImage != null) {
                    _formKey.currentState!.save();
                    ref.read(categoryProvider.notifier).addCategory(Category(name: categoryName, coverImage: coverImage!, id: DateTime.now().toString()));
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
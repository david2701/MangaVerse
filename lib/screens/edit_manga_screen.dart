// edit_manga_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';


class EditMangaScreen extends ConsumerStatefulWidget {
  final Manga manga;

  EditMangaScreen({required this.manga});

  @override
  _EditMangaScreenState createState() => _EditMangaScreenState();
}

class _EditMangaScreenState extends ConsumerState<EditMangaScreen> {
  bool isFavorite = false;
  bool isReading = false;
  bool isFinished = false;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.manga.isFavorite;
    isReading = widget.manga.isReading;
    isFinished = widget.manga.isFinished;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Manga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Favorito'),
              value: isFavorite,
              onChanged: (val) {
                setState(() {
                  isFavorite = val;
                });
              },
            ),
            SwitchListTile(
              title: Text('En Lectura'),
              value: isReading,
              onChanged: (val) {
                setState(() {
                  isReading = val;
                  if (val) isFinished = false;
                });
              },
            ),
            SwitchListTile(
              title: Text('Terminado'),
              value: isFinished,
              onChanged: (val) {
                setState(() {
                  isFinished = val;
                  if (val) isReading = false;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Guardar Cambios'),
              onPressed: () {
                ref.read(mangaProvider.notifier).updateMangaStatus(
                  widget.manga,
                  isFavorite: isFavorite,
                  isReading: isReading,
                  isFinished: isFinished,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
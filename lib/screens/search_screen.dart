// search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/manga_provider.dart';


class SearchScreen extends ConsumerStatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(mangaProvider).where((manga) => manga.title.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(hintText: 'Buscar mangas'),
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final manga = searchResults[index];
          return ListTile(
            leading: Image.file(manga.coverImage, width: 50, height: 70, fit: BoxFit.cover),
            title: Text(manga.title),
            onTap: () {
              Navigator.pushNamed(context, '/viewer', arguments: manga);
            },
          );
        },
      ),
    );
  }
}
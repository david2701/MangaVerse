// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_reader/providers/settings_provider.dart';
import 'models/category.dart';
import 'models/manga.dart';
import 'screens/home_screen.dart';
import 'screens/import_screen.dart';
import 'screens/viewer_screen.dart';
import 'screens/search_screen.dart';
import 'screens/add_category_screen.dart';
import 'screens/category_screen.dart';
import 'screens/edit_manga_screen.dart';
import 'screens/add_manga_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(ProviderScope(child: MangaReaderApp()));
}

class MangaReaderApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return MaterialApp(
      title: 'Manga Reader',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/import': (context) => ImportScreen(),
        '/viewer': (context) {
          final Manga manga = ModalRoute.of(context)!.settings.arguments as Manga;
          return ViewerScreen(manga: manga);
        },
        '/search': (context) => SearchScreen(),
        '/add_category': (context) => AddCategoryScreen(),
        '/category': (context) {
          final Category category = ModalRoute.of(context)!.settings.arguments as Category;
          return CategoryScreen(category: category);
        },
        '/edit_manga': (context) {
          final Manga manga = ModalRoute.of(context)!.settings.arguments as Manga;
          return EditMangaScreen(manga: manga);
        },
        '/add_manga': (context) => AddMangaScreen(),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
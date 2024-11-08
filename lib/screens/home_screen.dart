import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/manga.dart';
import '../providers/category_provider.dart';
import '../providers/manga_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryProvider);
    final favorites = ref.watch(favoritesProvider);
    final reading = ref.watch(readingProvider);
    final finished = ref.watch(finishedProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Manga Reader',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          IconButton(
            icon: Icon(Icons.folder_open, size: 22),
            onPressed: () => Navigator.pushNamed(context, '/import'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(96), // Altura para categorías + tabs
          child: Column(
            children: [
              // Categorías horizontales
              Container(
                height: 40,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category.name,
                          style: TextStyle(fontSize: 13),
                        ),
                        onSelected: (selected) {
                          Navigator.pushNamed(context, '/category', arguments: category);
                        },
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'Favoritos'),
                  Tab(text: 'En Lectura'),
                  Tab(text: 'Completados'),
                ],
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicatorSize: TabBarIndicatorSize.label,
                indicatorWeight: 2,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MangaGrid(mangas: favorites),
          MangaGrid(mangas: reading),
          MangaGrid(mangas: finished),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, size: 22),
        onPressed: () => Navigator.pushNamed(context, '/add_category'),
        elevation: 2,
        mini: true,
      ),
    );
  }
}

class MangaGrid extends StatelessWidget {
  final List<Manga> mangas;

  const MangaGrid({required this.mangas});

  @override
  Widget build(BuildContext context) {
    if (mangas.isEmpty) {
      return Center(
        child: Text(
          'No hay mangas en esta sección',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: mangas.length,
      itemBuilder: (context, index) {
        return MangaCard(manga: mangas[index]);
      },
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
      builder: (context) => MangaOptionsSheet(manga: manga, ref: ref),
    );
  }
}

class MangaOptionsSheet extends StatelessWidget {
  final Manga manga;
  final WidgetRef ref;

  const MangaOptionsSheet({required this.manga, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ],
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

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
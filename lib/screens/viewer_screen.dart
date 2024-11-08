// // lib/screens/viewer_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfx/pdfx.dart';
// import '../models/manga.dart';
// import '../providers/manga_provider.dart';
//
// class ViewerScreen extends ConsumerStatefulWidget {
//   final Manga manga;
//   ViewerScreen({required this.manga});
//
//   @override
//   _ViewerScreenState createState() => _ViewerScreenState();
// }
//
// class _ViewerScreenState extends ConsumerState<ViewerScreen> {
//   late PdfControllerPinch _pdfController;
//   int _currentPage = 1;
//   int _totalPages = 1;
//   bool isTwoPageView = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _pdfController = PdfControllerPinch(
//       document: PdfDocument.openFile(widget.manga.filePath),
//       initialPage: widget.manga.lastPage > 0 ? widget.manga.lastPage : 1,
//     );
//
//     _pdfController.addListener(() async {
//       int page = _pdfController.page ?? 1;
//       if (page != _currentPage) {
//         setState(() {
//           _currentPage = page;
//         });
//         ref.read(mangaProvider.notifier).updateLastPage(widget.manga, page);
//       }
//     });
//
//     _initializeTotalPages();
//   }
//
//   Future<void> _initializeTotalPages() async {
//     try {
//       final document = await PdfDocument.openFile(widget.manga.filePath);
//       final pageCount = await document.pagesCount;
//       setState(() {
//         _totalPages = pageCount;
//       });
//       await document.close();
//     } catch (e) {
//       print('Error al obtener el número total de páginas: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _pdfController.dispose();
//     super.dispose();
//   }
//
//   void _goToPreviousPage() {
//     if (_currentPage > 1) {
//       if (isTwoPageView) {
//         _pdfController.jumpToPage(_currentPage - 2);
//       } else {
//         _pdfController.previousPage(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//       }
//     }
//   }
//
//   void _goToNextPage() {
//     if (_currentPage < _totalPages) {
//       if (isTwoPageView) {
//         _pdfController.jumpToPage(_currentPage + 2);
//       } else {
//         _pdfController.nextPage(
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeIn,
//         );
//       }
//     }
//   }
//
//   void _jumpToPage() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController _pageController =
//         TextEditingController(text: _currentPage.toString());
//         return AlertDialog(
//           title: Text('Ir a la página'),
//           content: TextField(
//             controller: _pageController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: 'Número de página',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 int? page = int.tryParse(_pageController.text);
//                 if (page != null && page >= 1 && page <= _totalPages) {
//                   if (isTwoPageView) {
//                     if (page % 2 != 0 && page > 1) {
//                       page -= 1;
//                     }
//                   }
//                   _pdfController.jumpToPage(page);
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Número de página inválido')),
//                   );
//                 }
//               },
//               child: Text('Ir'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildPageControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.chevron_left),
//           onPressed: _goToPreviousPage,
//           tooltip: 'Página Anterior',
//         ),
//         Text('Página $_currentPage de $_totalPages'),
//         IconButton(
//           icon: Icon(Icons.chevron_right),
//           onPressed: _goToNextPage,
//           tooltip: 'Página Siguiente',
//         ),
//         IconButton(
//           icon: Icon(Icons.input),
//           onPressed: _jumpToPage,
//           tooltip: 'Ir a la página',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStateControls() {
//     final isFavorite = widget.manga.isFavorite;
//     final isReading = widget.manga.isReading;
//     final isFinished = widget.manga.isFinished;
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Favorito
//           IconButton(
//             icon: Icon(
//               isFavorite ? Icons.favorite : Icons.favorite_border,
//               color: isFavorite ? Colors.red : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isFavorite: !isFavorite,
//               );
//             },
//             tooltip: 'Favorito',
//           ),
//           SizedBox(width: 20),
//           // En Lectura
//           IconButton(
//             icon: Icon(
//               isReading ? Icons.book : Icons.book_outlined,
//               color: isReading ? Colors.blue : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isReading: !isReading,
//               );
//             },
//             tooltip: 'En Lectura',
//           ),
//           SizedBox(width: 20),
//           // Finalizado
//           IconButton(
//             icon: Icon(
//               isFinished ? Icons.check_circle : Icons.check_circle_outline,
//               color: isFinished ? Colors.green : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isFinished: !isFinished,
//               );
//             },
//             tooltip: 'Finalizado',
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTwoPageView() {
//     int leftPage = _currentPage;
//     int rightPage = _currentPage + 1;
//
//     if (leftPage % 2 == 0 && leftPage > 1) {
//       leftPage -= 1;
//       rightPage = leftPage + 1;
//     }
//
//     if (rightPage > _totalPages) {
//       rightPage = _totalPages;
//     }
//
//     return Row(
//       children: [
//         Expanded(
//           child: PdfViewPinch(
//             controller: _pdfController,
//             onPageChanged: (page) {
//               if (page != leftPage) {
//                 setState(() {
//                   _currentPage = page;
//                 });
//                 ref.read(mangaProvider.notifier).updateLastPage(widget.manga, page);
//               }
//             },
//             builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
//               options: DefaultBuilderOptions(),
//               documentLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//               pageLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//               errorBuilder: (_, error) => Center(child: Text(error.toString())),
//             ),
//           ),
//         ),
//         Expanded(
//           child: (rightPage <= _totalPages)
//               ? PdfViewPinch(
//             controller: _pdfController,
//             onPageChanged: (page) {
//               if (page != rightPage) {
//                 setState(() {
//                   _currentPage = page;
//                 });
//                 ref.read(mangaProvider.notifier).updateLastPage(widget.manga, page);
//               }
//             },
//             builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
//               options: DefaultBuilderOptions(),
//               documentLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//               pageLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//               errorBuilder: (_, error) => Center(child: Text(error.toString())),
//             ),
//           )
//               : Container(),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSinglePageView() {
//     return PdfViewPinch(
//       controller: _pdfController,
//       onDocumentLoaded: (document) {
//         setState(() {
//           _totalPages = document.pagesCount;
//         });
//       },
//       builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
//         options: DefaultBuilderOptions(),
//         documentLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//         pageLoaderBuilder: (_) => Center(child: CircularProgressIndicator()),
//         errorBuilder: (_, error) => Center(child: Text(error.toString())),
//       ),
//     );
//   }
//
//   void _toggleViewMode() {
//     setState(() {
//       isTwoPageView = !isTwoPageView;
//       if (isTwoPageView) {
//         if (_currentPage % 2 == 0 && _currentPage > 1) {
//           _currentPage -= 1;
//           _pdfController.jumpToPage(_currentPage);
//         }
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.manga.title),
//         actions: [
//           IconButton(
//             icon: Icon(isTwoPageView ? Icons.view_agenda : Icons.view_stream),
//             onPressed: _toggleViewMode,
//             tooltip: isTwoPageView ? 'Vista de Una Página' : 'Vista de Dos Páginas',
//           ),
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text(widget.manga.title),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Última página leída: $_currentPage'),
//                       Text('Categoría: ${widget.manga.categoryId}'),
//                     ],
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text('Cerrar'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//             tooltip: 'Información',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: isTwoPageView ? _buildTwoPageView() : _buildSinglePageView(),
//           ),
//           _buildPageControls(),
//           _buildStateControls(),
//         ],
//       ),
//     );
//   }
// }

// // lib/screens/viewer_screen.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:pdfx/pdfx.dart';
// import '../models/manga.dart';
// import '../providers/manga_provider.dart';
//
// class ViewerScreen extends ConsumerStatefulWidget {
//   final Manga manga;
//   ViewerScreen({required this.manga});
//
//   @override
//   _ViewerScreenState createState() => _ViewerScreenState();
// }
//
// class _ViewerScreenState extends ConsumerState<ViewerScreen> {
//   late PdfControllerPinch _pdfController;
//   int _currentPage = 1;
//   int _totalPages = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     _pdfController = PdfControllerPinch(
//       document: PdfDocument.openFile(widget.manga.filePath),
//       initialPage: widget.manga.lastPage > 0 ? widget.manga.lastPage : 1,
//     );
//
//     _pdfController.addListener(() async {
//       int page = _pdfController.page ?? 1;
//       if (page != _currentPage) {
//         setState(() {
//           _currentPage = page;
//         });
//         ref.read(mangaProvider.notifier).updateLastPage(widget.manga, page);
//       }
//     });
//
//     _initializeTotalPages();
//   }
//
//   Future<void> _initializeTotalPages() async {
//     try {
//       final document = await PdfDocument.openFile(widget.manga.filePath);
//       final pageCount = await document.pagesCount;
//       setState(() {
//         _totalPages = pageCount;
//       });
//       await document.close();
//     } catch (e) {
//       print('Error al obtener el número total de páginas: $e');
//     }
//   }
//
//   @override
//   void dispose() {
//     _pdfController.dispose();
//     super.dispose();
//   }
//
//   void _goToPreviousPage() {
//     if (_currentPage > 1) {
//       _pdfController.previousPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//     }
//   }
//
//   void _goToNextPage() {
//     if (_currentPage < _totalPages) {
//       _pdfController.nextPage(
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeIn,
//       );
//     }
//   }
//
//   void _jumpToPage() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         TextEditingController _pageController =
//         TextEditingController(text: _currentPage.toString());
//         return AlertDialog(
//           title: Text('Ir a la página'),
//           content: TextField(
//             controller: _pageController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               hintText: 'Número de página',
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancelar'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 int? page = int.tryParse(_pageController.text);
//                 if (page != null && page >= 1 && page <= _totalPages) {
//                   _pdfController.jumpToPage(page);
//                   Navigator.of(context).pop();
//                 } else {
//                   // Mostrar error si el número de página no es válido
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Número de página inválido')),
//                   );
//                 }
//               },
//               child: Text('Ir'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Widget _buildPageControls() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(
//           icon: Icon(Icons.chevron_left),
//           onPressed: _goToPreviousPage,
//         ),
//         Text('Página $_currentPage de $_totalPages'),
//         IconButton(
//           icon: Icon(Icons.chevron_right),
//           onPressed: _goToNextPage,
//         ),
//         IconButton(
//           icon: Icon(Icons.input),
//           onPressed: _jumpToPage,
//           tooltip: 'Ir a la página',
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStateControls() {
//     final isFavorite = widget.manga.isFavorite;
//     final isReading = widget.manga.isReading;
//     final isFinished = widget.manga.isFinished;
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Favorito
//           IconButton(
//             icon: Icon(
//               isFavorite ? Icons.favorite : Icons.favorite_border,
//               color: isFavorite ? Colors.red : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isFavorite: !isFavorite,
//               );
//             },
//             tooltip: 'Favorito',
//           ),
//           SizedBox(width: 20),
//           // En Lectura
//           IconButton(
//             icon: Icon(
//               isReading ? Icons.book : Icons.book_outlined,
//               color: isReading ? Colors.blue : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isReading: !isReading,
//               );
//             },
//             tooltip: 'En Lectura',
//           ),
//           SizedBox(width: 20),
//           // Finalizado
//           IconButton(
//             icon: Icon(
//               isFinished ? Icons.check_circle : Icons.check_circle_outline,
//               color: isFinished ? Colors.green : null,
//             ),
//             onPressed: () {
//               ref.read(mangaProvider.notifier).updateMangaStatus(
//                 widget.manga,
//                 isFinished: !isFinished,
//               );
//             },
//             tooltip: 'Finalizado',
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.manga.title),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.info_outline),
//             onPressed: () {
//               // Opcional: Mostrar información del manga
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: Text(widget.manga.title),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Text('Última página leída: $_currentPage'),
//                       Text('Categoría: ${widget.manga.categoryId}'),
//                       // Agrega más información si es necesario
//                     ],
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.of(context).pop(),
//                       child: Text('Cerrar'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//             tooltip: 'Información',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // PDF Viewer
//           Expanded(
//             child: PdfViewPinch(
//               controller: _pdfController,
//               onDocumentLoaded: (document) {
//                 setState(() {
//                   _totalPages = document.pagesCount;
//                 });
//               },
//             ),
//           ),
//           // Controles de Paginación
//           _buildPageControls(),
//           // Controles de Estado del Manga
//           _buildStateControls(),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';

enum ViewMode {
  single,
  double
}

class ViewerScreen extends ConsumerStatefulWidget {
  final Manga manga;
  ViewerScreen({required this.manga});

  @override
  _ViewerScreenState createState() => _ViewerScreenState();
}

class _ViewerScreenState extends ConsumerState<ViewerScreen> {
  late PdfControllerPinch _pdfController;
  int _currentPage = 1;
  int _totalPages = 1;
  ViewMode _viewMode = ViewMode.single;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openFile(widget.manga.filePath),
      initialPage: widget.manga.lastPage > 0 ? widget.manga.lastPage : 1,
    );

    _pdfController.addListener(() {
      int page = _pdfController.page ?? 1;
      if (page != _currentPage) {
        setState(() {
          _currentPage = page;
        });
        // Eliminar el await ya que updateLastPage maneja internamente la asincronía
        ref.read(mangaProvider.notifier).updateLastPage(widget.manga, page);
      }
    });

    _initializeTotalPages();
  }

  Future<void> _initializeTotalPages() async {
    try {
      final document = await PdfDocument.openFile(widget.manga.filePath);
      final pageCount = await document.pagesCount;
      setState(() {
        _totalPages = pageCount;
      });
      await document.close();
    } catch (e) {
      print('Error al obtener el número total de páginas: $e');
    }
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.single ? ViewMode.double : ViewMode.single;
      // Reinicializar el controlador con la nueva configuración
      _pdfController.dispose();
      _initializeController();
    });
  }

  Widget _buildPdfView() {
    if (_viewMode == ViewMode.single) {
      return PdfViewPinch(
        controller: _pdfController,
        onDocumentLoaded: (document) {
          setState(() {
            _totalPages = document.pagesCount;
          });
        },
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: DefaultBuilderOptions(
            loaderSwitchDuration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
      );
    } else {
      // Modo de vista doble
      return Row(
        children: [
          Expanded(
            child: PdfViewPinch(
              controller: _pdfController,
              onDocumentLoaded: (document) {
                setState(() {
                  _totalPages = document.pagesCount;
                });
              },
              builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                options: DefaultBuilderOptions(
                  loaderSwitchDuration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
          if (_currentPage < _totalPages)
            Expanded(
              child: PdfViewPinch(
                controller: PdfControllerPinch(
                  document: PdfDocument.openFile(widget.manga.filePath),
                  initialPage: _currentPage + 1,
                ),
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options: DefaultBuilderOptions(
                    loaderSwitchDuration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }

  Widget _buildPageControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).primaryColor,
              thumbColor: Theme.of(context).primaryColor,
              overlayColor: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
            child: Slider(
              value: _currentPage.toDouble(),
              min: 1,
              max: _totalPages.toDouble(),
              divisions: _totalPages - 1,
              label: 'Página $_currentPage',
              onChanged: (value) {
                _pdfController.jumpToPage(value.round());
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.first_page),
                onPressed: () => _pdfController.jumpToPage(1),
                tooltip: 'Primera página',
              ),
              IconButton(
                icon: Icon(Icons.chevron_left),
                onPressed: () => _pdfController.previousPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                tooltip: 'Página anterior',
              ),
              TextButton(
                onPressed: _jumpToPage,
                child: Text(
                  'Página $_currentPage de $_totalPages',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () => _pdfController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                tooltip: 'Página siguiente',
              ),
              IconButton(
                icon: Icon(Icons.last_page),
                onPressed: () => _pdfController.jumpToPage(_totalPages),
                tooltip: 'Última página',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateControls() {
    // Usar select para escuchar cambios específicos en el manga
    final manga = ref.watch(mangaProvider.select((state) =>
        state.firstWhere((m) => m.id == widget.manga.id)
    ));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStateButton(
            icon: manga.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: manga.isFavorite ? Colors.red : null,
            tooltip: 'Favorito',
            onPressed: () => ref.read(mangaProvider.notifier).updateMangaStatus(
              manga,
              isFavorite: !manga.isFavorite,
            ),
          ),
          _buildStateButton(
            icon: manga.isReading ? Icons.book : Icons.book_outlined,
            color: manga.isReading ? Colors.blue : null,
            tooltip: 'En Lectura',
            onPressed: () => ref.read(mangaProvider.notifier).updateMangaStatus(
              manga,
              isReading: !manga.isReading,
            ),
          ),
          _buildStateButton(
            icon: manga.isFinished ? Icons.check_circle : Icons.check_circle_outline,
            color: manga.isFinished ? Colors.green : null,
            tooltip: 'Finalizado',
            onPressed: () => ref.read(mangaProvider.notifier).updateMangaStatus(
              manga,
              isFinished: !manga.isFinished,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateButton({
    required IconData icon,
    Color? color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).iconTheme.color,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _jumpToPage() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController _pageController =
        TextEditingController(text: _currentPage.toString());
        return AlertDialog(
          title: Text('Ir a la página'),
          content: TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Número de página',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                int? page = int.tryParse(_pageController.text);
                if (page != null && page >= 1 && page <= _totalPages) {
                  _pdfController.jumpToPage(page);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Número de página inválido'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text('Ir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title),
        actions: [
          IconButton(
            icon: Icon(_viewMode == ViewMode.single
                ? Icons.book_outlined
                : Icons.chrome_reader_mode
            ),
            onPressed: _toggleViewMode,
            tooltip: 'Cambiar modo de vista',
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(widget.manga.title),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.bookmark),
                        title: Text('Última página'),
                        subtitle: Text('$_currentPage'),
                      ),
                      ListTile(
                        leading: Icon(Icons.category),
                        title: Text('Categoría'),
                        subtitle: Text(widget.manga.categoryId),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Información',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildPdfView(),
          ),
          _buildPageControls(),
          _buildStateControls(),
        ],
      ),
    );
  }
}
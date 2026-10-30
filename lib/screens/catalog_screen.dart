import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/catalog_controller.dart';
import '../data/character_repository.dart';
import '../widgets/character_image.dart';
import 'detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _catalog = CatalogController(CharacterRepository());
  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _catalog.addListener(_updated);
    _scroll.addListener(_onScroll);
    _catalog.loadMore();
  }

  void _updated() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _scroll.hasClients &&
          _catalog.error == null &&
          _scroll.position.extentAfter < 400) {
        _catalog.loadMore();
      }
    });
  }

  void _onScroll() {
    if (_scroll.position.extentAfter < 400 && _catalog.error == null) {
      _catalog.loadMore();
    }
  }

  void _onSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_scroll.hasClients) _scroll.jumpTo(0);
      _catalog.search(value);
    });
    setState(() {});
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _catalog.removeListener(_updated);
    _catalog.dispose();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'МУЛЬТИВСЕЛЕННАЯ',
                      style: TextStyle(
                        color: Color(0xffb5ed70),
                        letterSpacing: 3,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rick and Morty',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Каталог персонажей',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _search,
                      onChanged: _onSearch,
                      decoration: InputDecoration(
                        hintText: 'Поиск по имени',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Очистить поиск',
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  _search.clear();
                                  _onSearch('');
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _body() {
    if (_catalog.characters.isEmpty) {
      if (_catalog.loading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_catalog.error != null) {
        return _message(Icons.cloud_off, _catalog.error!, retry: true);
      }
      return _message(
        Icons.search_off,
        'Персонажи не найдены.\nПопробуйте другое имя.',
      );
    }
    return CustomScrollView(
      controller: _scroll,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final columns = (constraints.crossAxisExtent / 240).floor().clamp(
                2,
                4,
              );
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: constraints.crossAxisExtent / columns + 88,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final character = _catalog.characters[index];
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.zero,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DetailScreen(character: character),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: CharacterImage(url: character.image),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  character.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                StatusLabel(status: character.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _catalog.characters.length),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _catalog.loading
                ? const Center(child: CircularProgressIndicator())
                : _catalog.error != null
                ? _message(Icons.cloud_off, _catalog.error!, retry: true)
                : Center(
                    child: Text(
                      _catalog.hasNext
                          ? 'Прокрутите, чтобы увидеть больше'
                          : 'Вы посмотрели всех персонажей',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _message(IconData icon, String text, {bool retry = false}) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.white54),
          const SizedBox(height: 16),
          Text(text, textAlign: TextAlign.center),
          if (retry)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: FilledButton(
                onPressed: _catalog.loadMore,
                child: const Text('Повторить'),
              ),
            ),
        ],
      ),
    ),
  );
}

import 'package:flutter/foundation.dart';
import '../data/character_repository.dart';
import '../models/character.dart';

class CatalogController extends ChangeNotifier {
  CatalogController(this.repository);
  final CharacterRepository repository;
  final List<Character> _characters = [];
  List<Character> get characters => List.unmodifiable(_characters);
  String query = '';
  String? error;
  bool loading = false;
  bool hasNext = true;
  int _page = 1;
  int _generation = 0;
  bool _disposed = false;

  Future<void> search(String value) async {
    query = value.trim();
    _generation++;
    _page = 1;
    _characters.clear();
    hasNext = true;
    loading = false;
    error = null;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (loading || !hasNext || _disposed) return;
    final generation = _generation;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await repository.fetch(page: _page, name: query);
      if (_disposed || generation != _generation) return;
      _characters.addAll(result.characters);
      hasNext = result.hasNext;
      _page++;
    } catch (_) {
      if (_disposed || generation != _generation) return;
      error = 'Не удалось загрузить персонажей. Проверьте подключение.';
    } finally {
      if (!_disposed && generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    repository.dispose();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class CharacterPage {
  const CharacterPage(this.characters, this.hasNext);
  final List<Character> characters;
  final bool hasNext;
}

class CharacterRepository {
  CharacterRepository({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<CharacterPage> fetch({required int page, String name = ''}) async {
    final uri = Uri.https('rickandmortyapi.com', '/api/character', {
      'page': '$page',
      if (name.isNotEmpty) 'name': name,
    });
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 15));
    if (response.statusCode == 404) return const CharacterPage([], false);
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return CharacterPage(
      (json['results'] as List)
          .map((item) => Character.fromJson(item as Map<String, dynamic>))
          .toList(),
      json['info']['next'] != null,
    );
  }

  void dispose() => _client.close();
}

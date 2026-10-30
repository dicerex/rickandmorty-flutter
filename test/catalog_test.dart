import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rick_and_morty/controllers/catalog_controller.dart';
import 'package:rick_and_morty/data/character_repository.dart';

String page(String name, {bool next = false}) => jsonEncode({
  'info': {'next': next ? 'next' : null},
  'results': [
    {
      'id': 1,
      'name': name,
      'status': 'Alive',
      'species': 'Human',
      'image': 'https://example.com/image.jpg',
      'origin': {'name': 'Earth'},
      'location': {'name': 'Earth'},
    },
  ],
});

void main() {
  test(
    'pagination retries the failed page and keeps loaded characters',
    () async {
      final pages = <String?>[];
      var fail = true;
      final controller = CatalogController(
        CharacterRepository(
          client: MockClient((request) async {
            pages.add(request.url.queryParameters['page']);
            if (pages.last == '2' && fail) {
              fail = false;
              return http.Response('', 500);
            }
            return http.Response(page('Rick', next: pages.last == '1'), 200);
          }),
        ),
      );
      addTearDown(controller.dispose);
      await controller.loadMore();
      await controller.loadMore();
      expect(controller.characters.length, 1);
      expect(controller.error, isNotNull);
      await controller.loadMore();
      expect(pages, ['1', '2', '2']);
      expect(controller.characters.length, 2);
      expect(controller.hasNext, isFalse);
      expect(controller.error, isNull);
    },
  );

  test('a stale response does not overwrite a new search', () async {
    final old = Completer<http.Response>();
    final controller = CatalogController(
      CharacterRepository(
        client: MockClient((request) async {
          if (request.url.queryParameters['name'] == null) return old.future;
          expect(request.url.queryParameters['name'], 'Morty Smith');
          return http.Response(page('Morty Smith'), 200);
        }),
      ),
    );
    addTearDown(controller.dispose);
    final first = controller.loadMore();
    await controller.search(' Morty Smith ');
    old.complete(http.Response(page('Rick'), 200));
    await first;
    expect(controller.characters.single.name, 'Morty Smith');
    expect(controller.loading, isFalse);
  });

  test('404 is an empty result, not a network error', () async {
    final controller = CatalogController(
      CharacterRepository(
        client: MockClient((_) async => http.Response('', 404)),
      ),
    );
    addTearDown(controller.dispose);
    await controller.search('nonexistent');
    expect(controller.characters, isEmpty);
    expect(controller.error, isNull);
    expect(controller.hasNext, isFalse);
  });
}

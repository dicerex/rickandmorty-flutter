import 'package:flutter/material.dart';
import '../models/character.dart';
import '../widgets/character_image.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.character});
  final Character character;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('О персонаже')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CharacterImage(url: character.image),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                character.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              StatusLabel(status: character.status),
              const SizedBox(height: 24),
              _info('Вид', character.species),
              _info('Происхождение', character.origin),
              _info('Текущая локация', character.location),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _info(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54)),
        const SizedBox(height: 5),
        Text(
          value == 'unknown' ? 'Неизвестно' : value,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    ),
  );
}

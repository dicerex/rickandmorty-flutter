import 'package:flutter/material.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, progress) => progress == null
        ? child
        : const ColoredBox(
            color: Color(0xff243239),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
    errorBuilder: (context, error, stack) => const ColoredBox(
      color: Color(0xff243239),
      child: Center(child: Icon(Icons.broken_image_outlined, size: 40)),
    ),
  );
}

class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'Alive' => ('Жив', const Color(0xffb5ed70)),
      'Dead' => ('Мёртв', const Color(0xffff8585)),
      _ => ('Неизвестно', const Color(0xffaab5be)),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}

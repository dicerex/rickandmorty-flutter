import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';

void main() => runApp(const RickAndMortyApp());

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rick and Morty',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xffb5ed70),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xff101a20),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xff101a20)),
      cardTheme: const CardThemeData(color: Color(0xff1d2a31)),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1d2a31),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const CatalogScreen(),
  );
}

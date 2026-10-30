class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.origin,
    required this.location,
  });

  final int id;
  final String name, status, species, image, origin, location;

  factory Character.fromJson(Map<String, dynamic> json) => Character(
    id: json['id'] as int,
    name: json['name'] as String,
    status: json['status'] as String,
    species: json['species'] as String,
    image: json['image'] as String,
    origin: json['origin']['name'] as String,
    location: json['location']['name'] as String,
  );
}

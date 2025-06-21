class Publisher {
  final int id;
  final String name;
  final String country;

  Publisher({required this.id, required this.name, required this.country});

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['id'],
      name: json['name'], // updated key
      country: json['country'],
    );
  }
}

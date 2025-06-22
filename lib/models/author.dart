class Author {
  final int id;
  final String fName;
  final String lName;
  final String country;
  final String city;
  final String address;

  Author({
    required this.id,
    required this.fName,
    required this.lName,
    required this.country,
    required this.city,
    required this.address,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      fName: json['fName'], // صغير
      lName: json['lName'],
      country: json['country'],
      city: json['city'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fName': fName,
      'lName': lName,
      'country': country,
      'city': city,
      'address': address,
    };
  }
}

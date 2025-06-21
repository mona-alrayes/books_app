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
      fName: json['FName'],
      lName: json['LName'],
      country: json['Country'],
      city: json['City'],
      address: json['Address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FName': fName,
      'LName': lName,
      'Country': country,
      'City': city,
      'Address': address,
    };
  }
}

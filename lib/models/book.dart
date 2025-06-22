class Book {
  final int id;
  final String title;
  final String type;
  final double price;
  final String? coverImageUrl;
  final int publisherId;
  final int authorId;
  final String? authorName;
  final String? publisherName;

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.coverImageUrl,
    required this.publisherId,
    required this.authorId,
    this.authorName,
    this.publisherName,
  });

  // تحويل JSON إلى كائن Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['Title'],
      type: json['Type'],
      price: (json['Price'] is String)
          ? double.tryParse(json['Price']) ?? 0
          : (json['Price']?.toDouble() ?? 0),
      coverImageUrl: json['cover_image_url'],
      publisherId: json['publisher_id'],
      authorId: json['author_id'],
      authorName: json['author'] != null
          ? '${json['author']['FName']} ${json['author']['LName']}'
          : null,
      publisherName: json['publisher'] != null
          ? json['publisher']['PName']
          : null,
    );
  }

  // تحويل كائن Book إلى JSON (لإرسال إلى API مثلا)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Title': title,
      'Type': type,
      'Price': price.toString(),
      'cover_image_url': coverImageUrl,
      'Publisher_id': publisherId,
      'Author_id': authorId,
    };
  }
}

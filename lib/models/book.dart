class Book {
  final int id;
  final String title;
  final String type;
  final double price;
  final String? coverImageUrl;
  final int? publisherId;
  final int? authorId;
  final String? authorName;
  final String? publisherName;

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.coverImageUrl,
    this.publisherId,
    this.authorId,
    this.authorName,
    this.publisherName,
  });

  // تحويل JSON إلى كائن Book
  factory Book.fromJson(Map<String, dynamic> json) {
    print('=== DEBUG: Parsing Book JSON ===');
    print('Raw JSON: $json');
    
    // التعامل مع الحقول المختلفة من API
    final title = json['Title'] ?? json['title'] ?? 'Unknown Title';
    final type = json['Type'] ?? json['type'] ?? 'Unknown Type';
    final price = json['Price'] ?? json['price'];
    final coverImage = json['cover_image_url'] ?? json['coverImage'];
    final publisherId = json['publisher_id'];
    final authorId = json['author_id'];
    
    // التعامل مع السعر
    double priceValue = 0;
    if (price is String) {
      priceValue = double.tryParse(price) ?? 0;
    } else if (price is num) {
      priceValue = price.toDouble();
    }
    
    // التعامل مع المؤلف والناشر
    String? authorName;
    if (json['author'] != null && json['author'] is Map) {
      final author = json['author'] as Map;
      final fName = author['FName'] ?? author['fName'] ?? '';
      final lName = author['LName'] ?? author['lName'] ?? '';
      authorName = '$fName $lName'.trim();
    }
    
    String? publisherName;
    if (json['publisher'] != null && json['publisher'] is Map) {
      final publisher = json['publisher'] as Map;
      publisherName = publisher['PName'] ?? publisher['name'] ?? 'Unknown Publisher';
    }
    
    final book = Book(
      id: json['id'] ?? 0,
      title: title,
      type: type,
      price: priceValue,
      coverImageUrl: coverImage,
      publisherId: publisherId,
      authorId: authorId,
      authorName: authorName,
      publisherName: publisherName,
    );
    
    print('Parsed Book: ${book.title} (ID: ${book.id})');
    return book;
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

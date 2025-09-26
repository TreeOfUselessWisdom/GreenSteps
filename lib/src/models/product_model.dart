class ProductModel {
  final String id;
  final String title;
  final String description;
  final double? price;
  final int ecoScore;
  final List<String> tags;
  final String imageUrl;
  final String supplierUrl;
  final double rating;
  final String category;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    this.price,
    required this.ecoScore,
    required this.tags,
    required this.imageUrl,
    required this.supplierUrl,
    this.rating = 4.5,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'ecoScore': ecoScore,
      'tags': tags,
      'imageUrl': imageUrl,
      'supplierUrl': supplierUrl,
      'rating': rating,
      'category': category,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toDouble(),
      ecoScore: json['ecoScore'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      supplierUrl: json['supplierUrl'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      category: json['category'] ?? '',
    );
  }

  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    int? ecoScore,
    List<String>? tags,
    String? imageUrl,
    String? supplierUrl,
    double? rating,
    String? category,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      ecoScore: ecoScore ?? this.ecoScore,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      supplierUrl: supplierUrl ?? this.supplierUrl,
      rating: rating ?? this.rating,
      category: category ?? this.category,
    );
  }

  String get formattedPrice {
    if (price == null) return 'Price varies';
    return '\$${price!.toStringAsFixed(2)}';
  }

  String get ecoScoreLabel {
    if (ecoScore >= 90) return 'Excellent';
    if (ecoScore >= 80) return 'Very Good';
    if (ecoScore >= 70) return 'Good';
    if (ecoScore >= 60) return 'Fair';
    return 'Poor';
  }
}

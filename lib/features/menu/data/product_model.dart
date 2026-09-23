class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isAvailable;
  final String? imageUrl;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.isAvailable = true,
    this.imageUrl,
    this.stock = 0,
  });

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      imageUrl: map['imageUrl'] as String?,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    bool? isAvailable,
    String? imageUrl,
    int? stock,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }
}

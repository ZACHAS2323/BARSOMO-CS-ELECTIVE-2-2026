class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
    );
  }
}

class PaginatedProducts {
  const PaginatedProducts({required this.items, required this.totalCount});

  final List<Product> items;
  final int totalCount;
}

const int productsPerPage = 6;

({int start, int end}) pageRange(int page) {
  if (page < 0) {
    throw ArgumentError.value(page, 'page', 'Must be zero or greater');
  }
  final start = page * productsPerPage;
  return (start: start, end: start + productsPerPage - 1);
}

class CategoryModel {
  final String id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromMap(Map<String, dynamic> map) =>
      CategoryModel(id: map['id'] as String, name: map['name'] as String);
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String categoryId;
  final String? categoryName;
  final String? imageUrl;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.categoryName,
    this.imageUrl,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final category = map['categories'];
    return ProductModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] ?? '') as String,
      price: (map['price'] as num).toDouble(),
      stock: (map['stock'] as num).toInt(),
      categoryId: map['category_id'] as String,
      categoryName: category is Map ? category['name'] as String? : null,
      imageUrl: map['image_url'] as String?,
    );
  }
}

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get total => product.price * quantity;
}

class OrderModel {
  final String id;
  final String status;
  final DateTime createdAt;
  final double total;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.items,
  });
}

class OrderItemModel {
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });
}

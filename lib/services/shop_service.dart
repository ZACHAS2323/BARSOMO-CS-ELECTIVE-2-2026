import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';

class ShopService {
  ShopService(this._client);

  final SupabaseClient _client;

  Future<String?> roleForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('profiles')
        .select('roles(name)')
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return 'customer';
    final role = row['roles'];
    return role is Map ? role['name'] as String? : 'customer';
  }

  Future<List<CategoryModel>> categories() async {
    final rows = await _client
        .from('categories')
        .select('id,name')
        .order('name');
    return rows.map<CategoryModel>(CategoryModel.fromMap).toList();
  }

  Future<double> maximumProductPrice() async {
    final row = await _client
        .from('products')
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return 1;
    final price = (row['price'] as num).toDouble();
    return price > 0 ? price : 1;
  }

  Future<List<ProductModel>> products({
    String? categoryId,
    String? query,
  }) async {
    var request = _client
        .from('products')
        .select(
          'id,name,description,price,stock,category_id,image_url,categories(name)',
        );
    if (categoryId != null) {
      request = request.eq('category_id', categoryId);
    }
    if (query != null && query.trim().isNotEmpty) {
      request = request.ilike('name', '%${query.trim()}%');
    }
    final rows = await request.order('name');
    return rows.map<ProductModel>(ProductModel.fromMap).toList();
  }

  Future<PaginatedProducts> paginatedProducts({
    String? categoryId,
    String? query,
    required double minimumPrice,
    required double maximumPrice,
    required int page,
  }) async {
    final range = productPageRange(page);
    var request = _client
        .from('products')
        .select(
          'id,name,description,price,stock,category_id,image_url,categories(name)',
        );
    if (categoryId != null) {
      request = request.eq('category_id', categoryId);
    }
    if (query != null && query.trim().isNotEmpty) {
      request = request.ilike('name', '%${query.trim()}%');
    }
    final response = await request
        .gte('price', minimumPrice)
        .lte('price', maximumPrice)
        .order('name')
        .range(range.start, range.end)
        .count(CountOption.exact);
    return PaginatedProducts(
      items: response.data.map<ProductModel>(ProductModel.fromMap).toList(),
      totalCount: response.count,
    );
  }

  Future<void> createCategory(String name) async {
    await _client.from('categories').insert({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  Future<void> saveProduct({
    String? id,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List? imageBytes,
    required String? imageExtension,
    required String? imageContentType,
  }) async {
    String? imageUrl;
    if (imageBytes != null) {
      final extension =
          imageExtension?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') ?? 'jpg';
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}-${name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.$extension';
      await _client.storage
          .from('product-images')
          .uploadBinary(
            fileName,
            imageBytes,
            fileOptions: FileOptions(
              contentType: imageContentType ?? 'image/jpeg',
              upsert: true,
            ),
          );
      imageUrl = _client.storage.from('product-images').getPublicUrl(fileName);
    }
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
    };
    if (imageUrl != null) payload['image_url'] = imageUrl;
    if (id == null) {
      await _client.from('products').insert(payload);
    } else {
      await _client.from('products').update(payload).eq('id', id);
    }
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> checkout(List<CartItem> items) async {
    final payload = items
        .map(
          (item) => {'product_id': item.product.id, 'quantity': item.quantity},
        )
        .toList();
    final result = await _client.rpc('place_order', params: {'items': payload});
    return Map<String, dynamic>.from(result as Map);
  }

  Future<List<OrderModel>> customerOrders() async {
    final rows = await _client
        .from('orders')
        .select(
          'id,status,created_at,total,order_items(product_name,quantity,unit_price)',
        )
        .order('created_at', ascending: false);
    return rows.map<OrderModel>(_orderFromMap).toList();
  }

  Future<List<OrderModel>> allOrders() async {
    final rows = await _client
        .from('orders')
        .select(
          'id,status,created_at,total,order_items(product_name,quantity,unit_price)',
        )
        .order('created_at', ascending: false);
    return rows.map<OrderModel>(_orderFromMap).toList();
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', id);
  }

  OrderModel _orderFromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'] as List? ?? const [];
    final items = rawItems.map<OrderItemModel>((item) {
      final row = Map<String, dynamic>.from(item as Map);
      return OrderItemModel(
        productName: row['product_name'] as String,
        quantity: (row['quantity'] as num).toInt(),
        unitPrice: (row['unit_price'] as num).toDouble(),
      );
    }).toList();
    return OrderModel(
      id: map['id'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      total: (map['total'] as num).toDouble(),
      items: items,
    );
  }
}

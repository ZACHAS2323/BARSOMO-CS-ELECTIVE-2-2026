import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../services/shop_service.dart';

final shopServiceProvider = Provider<ShopService>((ref) {
  return ShopService(Supabase.instance.client);
});

final roleProvider = FutureProvider<String?>((ref) {
  return ref.watch(shopServiceProvider).roleForCurrentUser();
});

final categoryFilterProvider = StateProvider<String?>((ref) => null);
final searchProvider = StateProvider<String>((ref) => '');

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(shopServiceProvider).categories();
});

final productsProvider = FutureProvider<List<ProductModel>>((ref) {
  final category = ref.watch(categoryFilterProvider);
  final query = ref.watch(searchProvider);
  return ref
      .watch(shopServiceProvider)
      .products(categoryId: category, query: query);
});

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void add(ProductModel product) {
    if (product.stock <= 0) return;
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final item = state[index];
      if (item.quantity >= product.stock) return;
      item.quantity++;
      state = [...state];
    } else {
      state = [...state, CartItem(product: product, quantity: 1)];
    }
  }

  void setQuantity(ProductModel product, int quantity) {
    if (quantity <= 0) {
      remove(product.id);
      return;
    }
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index < 0) return;
    state[index].quantity = quantity.clamp(1, product.stock);
    state = [...state];
  }

  void remove(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clear() => state = [];

  double get total => state.fold(0, (sum, item) => sum + item.total);
  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final customerOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(shopServiceProvider).customerOrders();
});

final allOrdersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(shopServiceProvider).allOrders();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce_app/models/models.dart';
import 'package:flutter_ecommerce_app/providers/shop_providers.dart';

void main() {
  test('cart limits quantity to stock and calculates totals', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final product = ProductModel(
      id: 'shirt-1',
      name: 'Classic Cotton T-Shirt',
      description: '',
      price: 399,
      stock: 2,
      categoryId: 'shirts',
    );
    final cart = container.read(cartProvider.notifier);

    cart.add(product);
    cart.add(product);
    cart.add(product);

    expect(container.read(cartProvider).single.quantity, 2);
    expect(cart.itemCount, 2);
    expect(cart.total, 798);
  });
}

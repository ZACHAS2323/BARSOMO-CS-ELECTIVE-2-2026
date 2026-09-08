import 'package:flutter/foundation.dart';

import '../data/products.dart';
import 'product.dart';

class CartController extends ChangeNotifier {
  final Map<String, int> _quantities = {};

  List<CartLine> get lines => [
    for (final entry in _quantities.entries)
      CartLine(product: productsById[entry.key]!, quantity: entry.value),
  ];

  int get itemCount => _quantities.values.fold(0, (total, quantity) => total + quantity);

  double get total => lines.fold(0, (total, line) => total + line.subtotal);

  void add(Product product) {
    _quantities.update(product.id, (quantity) => quantity + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void increment(Product product) => add(product);

  void decrement(Product product) {
    final quantity = _quantities[product.id];
    if (quantity == null) return;
    if (quantity == 1) {
      _quantities.remove(product.id);
    } else {
      _quantities[product.id] = quantity - 1;
    }
    notifyListeners();
  }
}

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;
}

final productsById = {for (final product in products) product.id: product};

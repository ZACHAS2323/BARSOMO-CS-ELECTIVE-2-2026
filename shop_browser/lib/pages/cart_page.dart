import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart.dart';
import '../widgets/product_image.dart';

class CartPage extends StatelessWidget {
  const CartPage({required this.cart, super.key});

  final CartController cart;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: cart,
    builder: (context, child) => Scaffold(
      appBar: AppBar(title: const Text('Your bag')),
      body: cart.lines.isEmpty
          ? const _EmptyCart()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                Text('${cart.itemCount} item${cart.itemCount == 1 ? '' : 's'}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                for (final line in cart.lines) ...[
                  _CartLine(line: line, cart: cart),
                  const SizedBox(height: 12),
                ],
                const Divider(height: 28),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Subtotal', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ]),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.go('/checkout'),
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Proceed to checkout'),
                ),
              ],
            ),
    ),
  );
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.line, required this.cart});

  final CartLine line;
  final CartController cart;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        SizedBox(width: 84, height: 84, child: ProductImage(product: line.product)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(line.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text('\$${line.subtotal.toStringAsFixed(2)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            IconButton(onPressed: () => cart.decrement(line.product), icon: const Icon(Icons.remove), visualDensity: VisualDensity.compact, tooltip: 'Decrease quantity'),
            Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
            IconButton(onPressed: () => cart.increment(line.product), icon: const Icon(Icons.add), visualDensity: VisualDensity.compact, tooltip: 'Increase quantity'),
          ]),
        ])),
      ]),
    ),
  );
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.shopping_bag_outlined, size: 64),
    const SizedBox(height: 16),
    Text('Your bag is empty', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
    const SizedBox(height: 20),
    OutlinedButton(onPressed: () => context.go('/'), child: const Text('Browse the shop')),
  ])));
}

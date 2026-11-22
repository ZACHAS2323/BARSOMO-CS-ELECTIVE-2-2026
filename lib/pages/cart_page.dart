import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shop_providers.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _checkingOut = false;

  Future<void> _checkout() async {
    setState(() => _checkingOut = true);
    try {
      final items = ref.read(cartProvider);
      final result = await ref.read(shopServiceProvider).checkout(items);
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(customerOrdersProvider);
      ref.invalidate(productsProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Order confirmed'),
          content: Text(
            'Order ${result['order_id']} was placed.\n'
            'Total: ₱${(result['total'] as num).toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Checkout failed: $error')));
    } finally {
      if (mounted) setState(() => _checkingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final total = cart.fold<double>(
      0,
      (sum, item) => sum + item.product.price * item.quantity,
    );
    final count = cart.fold<int>(0, (sum, item) => sum + item.quantity);

    if (cart.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64),
            SizedBox(height: 12),
            Text('Your cart is empty'),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final item = cart[index];
              return Card(
                child: ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('₱${item.product.price.toStringAsFixed(2)}'),
                  trailing: SizedBox(
                    width: 180,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => notifier.setQuantity(
                            item.product,
                            item.quantity - 1,
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          onPressed: item.quantity >= item.product.stock
                              ? null
                              : () => notifier.setQuantity(
                                  item.product,
                                  item.quantity + 1,
                                ),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        IconButton(
                          tooltip: 'Remove',
                          onPressed: () => notifier.remove(item.product.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('$count items'),
              Text(
                'Total: ₱${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _checkingOut ? null : _checkout,
                child: _checkingOut
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Checkout'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

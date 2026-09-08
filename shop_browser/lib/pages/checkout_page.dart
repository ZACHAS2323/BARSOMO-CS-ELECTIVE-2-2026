import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/cart.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({required this.cart, super.key});

  final CartController cart;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Order confirmed')),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      children: [
        Icon(Icons.check_circle_outline, size: 72, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 18),
        Text('Thanks for your order!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        const Text('Your Threadline pieces are being prepared.', textAlign: TextAlign.center),
        const SizedBox(height: 32),
        const Text('ORDER SUMMARY', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          for (final line in cart.lines) ...[
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text('${line.product.name} x${line.quantity}')),
              Text('\$${line.subtotal.toStringAsFixed(2)}'),
            ]),
            const SizedBox(height: 12),
          ],
          const Divider(),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('\$${cart.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w900)),
          ]),
        ]))),
        const SizedBox(height: 24),
        FilledButton(onPressed: () => context.go('/'), child: const Text('Continue shopping')),
      ],
    ),
  );
}

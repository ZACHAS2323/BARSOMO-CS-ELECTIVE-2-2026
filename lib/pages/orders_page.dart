import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shop_providers.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(customerOrdersProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(customerOrdersProvider),
      child: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load orders: $error'),
            ),
          ],
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final order = items[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.id.substring(0, 8).toUpperCase()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('${order.status} - ${order.createdAt.toLocal()}'),
                      Text(
                        '₱${order.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const Divider(),
                      ...order.items.map(
                        (item) => Text(
                          '${item.quantity} × ${item.productName} '
                          '- ₱${item.unitPrice.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

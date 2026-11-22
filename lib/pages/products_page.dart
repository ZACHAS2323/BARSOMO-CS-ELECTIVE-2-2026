import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../providers/shop_providers.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final products = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);
    final selectedCategory = ref.watch(categoryFilterProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(categoriesProvider);
        ref.invalidate(productsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search products',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                ref.read(searchProvider.notifier).state = value,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: categories.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('Categories unavailable: $error'),
              data: (items) => ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: selectedCategory == null,
                      onSelected: (_) =>
                          ref.read(categoryFilterProvider.notifier).state =
                              null,
                    ),
                  ),
                  ...items.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.name),
                        selected: selectedCategory == category.id,
                        onSelected: (_) =>
                            ref.read(categoryFilterProvider.notifier).state =
                                category.id,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          products.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 80),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text('Could not load products: $error'),
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('No products match your filters.')),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 280,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final product = items[index];
                  final inCart = cart.where(
                    (item) => item.product.id == product.id,
                  );
                  final quantity = inCart.isEmpty ? 0 : inCart.first.quantity;
                  return _ProductCard(product: product, cartQuantity: quantity);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product, required this.cartQuantity});

  final ProductModel product;
  final int cartQuantity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final atStockLimit = cartQuantity >= product.stock;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: product.imageUrl == null
                ? const ColoredBox(
                    color: Color(0xFFEDE7F6),
                    child: Center(
                      child: Icon(Icons.shopping_bag_outlined, size: 48),
                    ),
                  )
                : Image.network(
                    product.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text('₱${product.price.toStringAsFixed(2)}'),
                Text(
                  '${product.stock} in stock',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: product.stock == 0 || atStockLimit
                        ? null
                        : () => ref.read(cartProvider.notifier).add(product),
                    child: Text(
                      product.stock == 0
                          ? 'Out of stock'
                          : atStockLimit
                          ? 'Stock limit'
                          : 'Add to cart',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

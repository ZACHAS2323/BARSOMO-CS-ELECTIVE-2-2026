import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../widgets/product_image.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.product, required this.onAddToCart, super.key});

  final Product product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Product details'),
      leading: BackButton(onPressed: () => context.go('/')),
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final content = [
          AspectRatio(
            aspectRatio: 1,
            child: ProductImage(product: product, iconSize: 96),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'A dependable layer made for repeat wear. Easy to style, comfortable through the day, and ready for whatever is next.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                const Text('SELECT SIZE', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final size in ['S', 'M', 'L', 'XL'])
                      ChoiceChip(label: Text(size), selected: size == 'M', onSelected: (_) {}),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAddToCart,
                    icon: const Icon(Icons.shopping_bag_outlined),
                    label: const Text('Add to bag'),
                  ),
                ),
              ],
            ),
          ),
        ];

        if (constraints.maxWidth >= 700) {
          return SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content.first),
                Expanded(child: content.last),
              ],
            ),
          );
        }
        return ListView(children: content);
      },
    ),
  );
}

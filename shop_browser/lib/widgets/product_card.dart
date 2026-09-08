import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ProductImage(product: product)),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.category.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 7),
                Text(
                  '\$${product.price.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

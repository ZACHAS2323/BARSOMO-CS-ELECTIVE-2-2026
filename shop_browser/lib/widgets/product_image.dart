import 'package:flutter/material.dart';

import '../models/product.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({required this.product, this.iconSize = 48, super.key});

  final Product product;
  final double iconSize;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: product.color,
    child: Image.network(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(Icons.checkroom_outlined, size: iconSize),
      ),
      loadingBuilder: (context, child, loadingProgress) => loadingProgress == null
          ? child
          : Center(child: Icon(Icons.checkroom_outlined, size: iconSize)),
    ),
  );
}

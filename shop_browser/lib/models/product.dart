import 'package:flutter/material.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.color,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final Color color;
  final String imageUrl;
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Product details')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Product not found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: () => context.go('/'), child: const Text('Back to shop')),
          ],
        ),
      ),
    ),
  );
}

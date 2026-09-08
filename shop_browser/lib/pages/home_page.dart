import 'package:flutter/material.dart';

import '../data/products.dart';
import '../widgets/product_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onToggleTheme, required this.cartItemCount, required this.onOpenCart, super.key});

  final VoidCallback onToggleTheme;
  final int cartItemCount;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'THREADLINE',
        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
      ),
      actions: [
        Stack(alignment: Alignment.topRight, children: [
          IconButton(onPressed: onOpenCart, tooltip: 'Open cart', icon: const Icon(Icons.shopping_bag_outlined)),
          if (cartItemCount > 0)
            IgnorePointer(child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
              child: Text('$cartItemCount', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
            )),
        ]),
        IconButton(
          onPressed: onToggleTheme,
          tooltip: 'Toggle theme',
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 800 ? 3 : 2;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THE SHIRT EDIT',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Good shirts.\nBetter habits.',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: .98,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Six dependable layers, designed to be worn on repeat.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 18),
                    const Text('6 pieces', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              sliver: SliverGrid.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 22,
                  childAspectRatio: columns == 2 ? .72 : .82,
                ),
                itemBuilder: (context, index) => ProductCard(product: products[index]),
              ),
            ),
          ],
        );
      },
    ),
  );
}

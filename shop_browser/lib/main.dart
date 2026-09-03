import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() => runApp(const ShirtShopApp());

class Product {
  const Product({required this.id, required this.name, required this.category, required this.price, required this.color});
  final String id;
  final String name;
  final String category;
  final double price;
  final Color color;
}

const products = [
  Product(id: 'studio-tee', name: 'Studio Heavy Tee', category: 'Everyday essential', price: 32, color: Color(0xffd8b8a8)),
  Product(id: 'linen-shirt', name: 'Linen Camp Shirt', category: 'Warm weather', price: 58, color: Color(0xffe7d6b4)),
  Product(id: 'oxford-shirt', name: 'Sunday Oxford', category: 'Smart casual', price: 64, color: Color(0xffb8c9d8)),
  Product(id: 'workshirt', name: 'Canvas Workshirt', category: 'Utility layer', price: 76, color: Color(0xffb7b09a)),
  Product(id: 'knit-polo', name: 'Riviera Knit Polo', category: 'Light knitwear', price: 68, color: Color(0xffd1a7a3)),
  Product(id: 'flannel-shirt', name: 'Brushed Flannel', category: 'Layering piece', price: 72, color: Color(0xffaeb9ad)),
];

class ShirtShopApp extends StatefulWidget {
  const ShirtShopApp({super.key});
  @override
  State<ShirtShopApp> createState() => _ShirtShopAppState();
}

class _ShirtShopAppState extends State<ShirtShopApp> {
  late final GoRouter router;
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => HomePage(onToggleTheme: () => setState(() => isDark = !isDark))),
      GoRoute(path: '/product/:id', builder: (context, state) {
        final product = products.firstWhere((item) => item.id == state.pathParameters['id']);
        return ProductDetailPage(product: product);
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Threadline',
    theme: buildTheme(Brightness.light),
    darkTheme: buildTheme(Brightness.dark),
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    routerConfig: router,
  );
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xffe85d3f), brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xfffffbf6) : null,
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
    cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({required this.onToggleTheme, super.key});
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('THREADLINE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      actions: [
        IconButton(onPressed: onToggleTheme, tooltip: 'Toggle theme', icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
        const SizedBox(width: 8),
      ],
    ),
    body: LayoutBuilder(builder: (context, constraints) {
      final columns = constraints.maxWidth >= 800 ? 3 : 2;
      return CustomScrollView(slivers: [
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 26, 20, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('THE SHIRT EDIT', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text('Good shirts.\nBetter habits.', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, height: .98)),
          const SizedBox(height: 12),
          Text('Six dependable layers, designed to be worn on repeat.', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          const Text('6 pieces', style: TextStyle(fontWeight: FontWeight.bold)),
        ]))),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 32), sliver: SliverGrid.builder(
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: 16, mainAxisSpacing: 22, childAspectRatio: columns == 2 ? .72 : .82),
          itemBuilder: (context, index) => ProductCard(product: products[index]),
        )),
      ]);
    }),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});
  final Product product;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(color: product.color, child: const Center(child: Icon(Icons.checkroom_outlined, size: 48)))),
        Padding(padding: const EdgeInsets.fromLTRB(12, 12, 12, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(product.category.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 7),
          Text('\$${product.price.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800)),
        ])),
      ]),
    ),
  );
}

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({required this.product, super.key});
  final Product product;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Product details')),
    body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.construction_outlined, size: 64),
      const SizedBox(height: 18),
      Text(product.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      const Text('Product details are coming next.', textAlign: TextAlign.center),
      const SizedBox(height: 24),
      OutlinedButton(onPressed: () => context.go('/'), child: const Text('Back to shop')),
    ]))),
  );
}

class MyApp extends ShirtShopApp {
  const MyApp({super.key});
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/products.dart';
import 'models/cart.dart';
import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/home_page.dart';
import 'pages/not_found_page.dart';
import 'pages/product_detail_page.dart';
import 'theme/app_theme.dart';

class ShirtShopApp extends StatefulWidget {
  const ShirtShopApp({super.key});

  @override
  State<ShirtShopApp> createState() => _ShirtShopAppState();
}

class _ShirtShopAppState extends State<ShirtShopApp> {
  late final GoRouter router;
  final cart = CartController();
  bool isDark = false;

  @override
  void initState() {
    super.initState();
    cart.addListener(_onCartChanged);
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomePage(
            onToggleTheme: () => setState(() => isDark = !isDark),
            cartItemCount: cart.itemCount,
            onOpenCart: () => context.go('/cart'),
          ),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final matches = products.where((item) => item.id == state.pathParameters['id']);
            if (matches.isEmpty) {
              return const NotFoundPage();
            }
            return ProductDetailPage(
              product: matches.first,
              onAddToCart: () {
                cart.add(matches.first);
                context.go('/cart');
              },
            );
          },
        ),
        GoRoute(path: '/cart', builder: (context, state) => CartPage(cart: cart)),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => cart.lines.isEmpty
              ? CartPage(cart: cart)
              : CheckoutPage(cart: cart),
        ),
      ],
    );
  }

  void _onCartChanged() => setState(() {});

  @override
  void dispose() {
    cart.removeListener(_onCartChanged);
    cart.dispose();
    router.dispose();
    super.dispose();
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

class MyApp extends ShirtShopApp {
  const MyApp({super.key});
}

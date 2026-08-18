import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const FruitApp());
}

// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const FruitListScreen();
      },
      // Nested routes defined here
      routes: <RouteBase>[
        GoRoute(
          path: 'fruit/:name', // The URL resolves to /fruit/:name
          builder: (BuildContext context, GoRouterState state) {
            final String fruitName = state.pathParameters['name']!;
            return FruitDetailScreen(fruitName: fruitName);
          },
        ),
      ],
    ),
  ],
);

class FruitApp extends StatelessWidget {
  const FruitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fruit Router Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      routerConfig: _router,
    );
  }
}

// First Page: List of Fruits at "/"
class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  final List<String> fruits = const [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Watermelon',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fruit List')),
      body: ListView.builder(
        itemCount: fruits.length,
        itemBuilder: (context, index) {
          final fruit = fruits[index];
          return ListTile(
            title: Text(fruit),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigating to the nested route
              context.go('/fruit/${fruit.toLowerCase()}');
            },
          );
        },
      ),
    );
  }
}

// Second Page: Fruit Illustration at "/fruit/:name"
class FruitDetailScreen extends StatelessWidget {
  final String fruitName;

  const FruitDetailScreen({super.key, required this.fruitName});

  // Helper method to provide an "illustration" (emoji) based on the fruit name
  String _getFruitIllustration(String name) {
    switch (name.toLowerCase()) {
      case 'apple':
        return '🍎';
      case 'banana':
        return '🍌';
      case 'orange':
        return '🍊';
      case 'grapes':
        return '🍇';
      case 'watermelon':
        return '🍉';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fruitName.toUpperCase())),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getFruitIllustration(fruitName),
              style: const TextStyle(
                fontSize: 120,
              ), // Large size for the illustration
            ),
            const SizedBox(height: 20),
            Text(
              'This is the illustration for $fruitName',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

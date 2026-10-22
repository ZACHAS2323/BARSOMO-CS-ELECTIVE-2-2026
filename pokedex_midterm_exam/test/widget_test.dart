import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pokedex_midterm_exam/data/pokemon_repository.dart';
import 'package:pokedex_midterm_exam/main.dart';

void main() {
  testWidgets('loads Pokémon and updates nickname and favorite state', (
    tester,
  ) async {
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/type/fire')) {
        return http.Response(
          jsonEncode({
            'pokemon': [
              {
                'pokemon': {
                  'name': 'charmander',
                  'url': 'https://pokeapi.co/api/v2/pokemon/4/',
                },
              },
            ],
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/pokemon')) {
        return http.Response(
          jsonEncode({
            'results': [
              {
                'name': 'bulbasaur',
                'url': 'https://pokeapi.co/api/v2/pokemon/1/',
              },
            ],
          }),
          200,
        );
      }
      return http.Response('{}', 404);
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [httpClientProvider.overrideWith((ref) => client)],
        child: const PokedexApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bulbasaur'), findsOneWidget);
    await tester.tap(find.byTooltip('Add Bulbasaur to favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites (1)'), findsOneWidget);

    await tester.tap(find.text('Nickname'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sprout');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Nickname: Sprout'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);

    await tester.tap(find.text('Edit nickname'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();
    expect(find.text('Nickname: Sprout'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fire').last);
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsNothing);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All types').last);
    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
  });

  testWidgets('shows a useful message when the PokéAPI request fails', (
    tester,
  ) async {
    final client = MockClient(
      (request) async => http.Response('Unavailable', 503),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [httpClientProvider.overrideWith((ref) => client)],
        child: const PokedexApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Unable to load Pokémon.'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });
}

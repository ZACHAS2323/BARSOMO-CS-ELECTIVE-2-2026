import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository(ref.watch(httpClientProvider));
});

final pokemonDetailProvider =
    FutureProvider.family<PokemonDetails, int>((ref, pokemonId) {
      return ref
          .watch(pokemonRepositoryProvider)
          .fetchPokemonDetails(pokemonId);
    });

class PokemonRepository {
  PokemonRepository(this._client);

  final http.Client _client;
  static const _baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<Pokemon>> fetchPokemon({String? type}) async {
    if (type != null) {
      final response = await _getJson('$_baseUrl/type/$type');
      final entries = response['pokemon'];
      if (entries is! List) {
        throw const FormatException('PokéAPI returned an invalid type list.');
      }
      return entries.map((entry) {
        if (entry is! Map<String, dynamic> ||
            entry['pokemon'] is! Map<String, dynamic>) {
          throw const FormatException('PokéAPI returned an invalid Pokémon entry.');
        }
        return Pokemon.fromApiSummary(
          entry['pokemon'] as Map<String, dynamic>,
          types: [type],
        );
      }).toList(growable: false);
    }

    final response = await _getJson('$_baseUrl/pokemon?limit=151');
    final results = response['results'];
    if (results is! List) {
      throw const FormatException('PokéAPI returned an invalid Pokémon list.');
    }
    return results
        .map((entry) {
          if (entry is! Map<String, dynamic>) {
            throw const FormatException('PokéAPI returned an invalid Pokémon entry.');
          }
          return Pokemon.fromApiSummary(entry);
        })
        .toList(growable: false);
  }

  Future<PokemonDetails> fetchPokemonDetails(int pokemonId) async {
    final response = await _getJson('$_baseUrl/pokemon/$pokemonId');
    return PokemonDetails.fromApiJson(response);
  }

  Future<Map<String, dynamic>> _getJson(String url) async {
    final uri = Uri.parse(url);
    final response = await _client.get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'PokéAPI request failed with status ${response.statusCode}.',
        uri: uri,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('PokéAPI returned an invalid response.');
    }
    return decoded;
  }
}

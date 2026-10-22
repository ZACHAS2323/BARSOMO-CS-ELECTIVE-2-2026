class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.types,
  });

  final int id;
  final String name;
  final List<String> types;

  factory Pokemon.fromApiSummary(
    Map<String, dynamic> json, {
    List<String> types = const [],
  }) {
    final name = json['name'];
    final url = json['url'];
    if (name is! String || url is! String) {
      throw const FormatException('Pokémon response is missing its name or URL.');
    }

    final match = RegExp(r'/pokemon/(\d+)/?').firstMatch(url);
    final id = int.tryParse(match?.group(1) ?? '');
    if (id == null) {
      throw FormatException('Could not read the Pokémon ID from "$url".');
    }

    return Pokemon(id: id, name: name, types: types);
  }
}

class PokemonDetails {
  const PokemonDetails({
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
  });

  final int height;
  final int weight;
  final List<String> types;
  final Map<String, int> stats;

  factory PokemonDetails.fromApiJson(Map<String, dynamic> json) {
    final rawTypes = json['types'];
    final rawStats = json['stats'];
    final height = json['height'];
    final weight = json['weight'];
    if (rawTypes is! List || rawStats is! List || height is! int || weight is! int) {
      throw const FormatException('Pokémon detail response is incomplete.');
    }

    final types = rawTypes.map((entry) {
      if (entry is! Map<String, dynamic> ||
          entry['type'] is! Map<String, dynamic> ||
          (entry['type'] as Map<String, dynamic>)['name'] is! String) {
        throw const FormatException('Pokémon type response is invalid.');
      }
      return (entry['type'] as Map<String, dynamic>)['name'] as String;
    }).toList(growable: false);

    final stats = <String, int>{};
    for (final entry in rawStats) {
      if (entry is! Map<String, dynamic> ||
          entry['stat'] is! Map<String, dynamic> ||
          (entry['stat'] as Map<String, dynamic>)['name'] is! String ||
          entry['base_stat'] is! int) {
        throw const FormatException('Pokémon stat response is invalid.');
      }
      stats[(entry['stat'] as Map<String, dynamic>)['name'] as String] =
          entry['base_stat'] as int;
    }

    return PokemonDetails(
      height: height,
      weight: weight,
      types: types,
      stats: stats,
    );
  }
}

import 'package:flutter/material.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    required this.pokemon,
    required this.nickname,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onEditNickname,
    required this.onShowDetails,
    super.key,
  });

  final Pokemon pokemon;
  final String? nickname;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onEditNickname;
  final VoidCallback onShowDetails;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remove ${_capitalize(pokemon.name)} from favorites'
                      : 'Add ${_capitalize(pokemon.name)} to favorites',
                  onPressed: onToggleFavorite,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFE5483F) : null,
                  ),
                ),
              ],
            ),
            Expanded(
              child: InkWell(
                onTap: onShowDetails,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.network(
                        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.catching_pokemon,
                          size: 64,
                        ),
                      ),
                    ),
                    Text(
                      _capitalize(pokemon.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (nickname != null)
                      Text(
                        'Nickname: $nickname',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onEditNickname,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(nickname == null ? 'Nickname' : 'Edit nickname'),
            ),
          ],
        ),
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

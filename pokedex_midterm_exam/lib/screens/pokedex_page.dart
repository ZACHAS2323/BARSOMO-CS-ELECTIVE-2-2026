import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pokemon_repository.dart';
import '../models/pokemon.dart';
import '../state/pokedex_controller.dart';
import '../widgets/pokemon_card.dart';

const _pokemonTypes = [
  'normal',
  'fire',
  'water',
  'electric',
  'grass',
  'ice',
  'fighting',
  'poison',
  'ground',
  'flying',
  'psychic',
  'bug',
  'rock',
  'ghost',
  'dragon',
  'dark',
  'steel',
  'fairy',
];

class PokedexPage extends ConsumerWidget {
  const PokedexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pokedexControllerProvider);
    final controller = ref.read(pokedexControllerProvider.notifier);
    final favorites = state.favorites
        .map((id) => state.knownPokemonById[id])
        .whereType<Pokemon>()
        .toList()
      ..sort((first, second) => first.id.compareTo(second.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            tooltip: 'Refresh Pokémon',
            onPressed: state.isLoading ? null : controller.fetchPokemon,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Discover, favorite, and make each Pokémon your own.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              _FavoritesPanel(
                favorites: favorites,
                nicknames: state.nicknames,
                onRemove: controller.toggleFavorite,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: DropdownButtonFormField<String>(
                  initialValue: state.selectedType ?? 'all',
                  decoration: const InputDecoration(
                    labelText: 'Filter by type',
                    prefixIcon: Icon(Icons.filter_list),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'all',
                      child: Text('All types'),
                    ),
                    for (final type in _pokemonTypes)
                      DropdownMenuItem(
                        value: type,
                        child: Text(_capitalize(type)),
                      ),
                  ],
                  onChanged: (value) {
                    controller.setTypeFilter(value == 'all' ? null : value);
                  },
                ),
              ),
              if (state.isLoading && state.pokemon.isNotEmpty)
                const LinearProgressIndicator(),
              if (state.errorMessage != null && state.pokemon.isNotEmpty)
                _InlineError(
                  message: state.errorMessage!,
                  onRetry: controller.fetchPokemon,
                ),
              Expanded(
                child: _PokemonResults(
                  state: state,
                  onRefresh: controller.fetchPokemon,
                  onRetry: controller.fetchPokemon,
                  onToggleFavorite: controller.toggleFavorite,
                  onEditNickname: (pokemon) => _editNickname(
                    context,
                    ref,
                    pokemon,
                    state.nicknames[pokemon.id],
                  ),
                  onShowDetails: (pokemon) => _showDetails(context, pokemon),
                  onClearFilter: () => controller.setTypeFilter(null),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editNickname(
    BuildContext context,
    WidgetRef ref,
    Pokemon pokemon,
    String? currentNickname,
  ) async {
    final nickname = await showDialog<String>(
      context: context,
      builder: (context) =>
          _NicknameDialog(pokemon: pokemon, currentNickname: currentNickname),
    );
    if (!context.mounted || nickname == null) return;
    ref.read(pokedexControllerProvider.notifier).setNickname(pokemon.id, nickname);
  }

  void _showDetails(BuildContext context, Pokemon pokemon) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          child: Consumer(
            builder: (context, ref, _) {
              final detail = ref.watch(pokemonDetailProvider(pokemon.id));
              return detail.when(
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SizedBox(
                  height: 220,
                  child: Center(
                    child: Text('Unable to load details. $error'),
                  ),
                ),
                data: (details) => _PokemonDetailsView(
                  pokemon: pokemon,
                  details: details,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FavoritesPanel extends StatelessWidget {
  const _FavoritesPanel({
    required this.favorites,
    required this.nicknames,
    required this.onRemove,
  });

  final List<Pokemon> favorites;
  final Map<int, String> nicknames;
  final ValueChanged<Pokemon> onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        leading: const Icon(Icons.favorite, color: Color(0xFFE5483F)),
        title: Text('Favorites (${favorites.length})'),
        children: [
          if (favorites.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Text('No favorites yet. Tap a heart to save a Pokémon.'),
            )
          else
            SizedBox(
              height: 76,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final pokemon = favorites[index];
                  final nickname = nicknames[pokemon.id];
                  return InputChip(
                    avatar: CircleAvatar(
                      backgroundColor: const Color(0xFFFFE5E0),
                      child: Text('#${pokemon.id}'),
                    ),
                    label: Text(nickname ?? _capitalize(pokemon.name)),
                    onDeleted: () => onRemove(pokemon),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _PokemonResults extends StatelessWidget {
  const _PokemonResults({
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onToggleFavorite,
    required this.onEditNickname,
    required this.onShowDetails,
    required this.onClearFilter,
  });

  final PokedexState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;
  final ValueChanged<Pokemon> onToggleFavorite;
  final ValueChanged<Pokemon> onEditNickname;
  final ValueChanged<Pokemon> onShowDetails;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.pokemon.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 170),
            Center(child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Center(child: Text('Loading Pokémon...')),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.pokemon.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            const Icon(Icons.cloud_off, size: 44),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(state.errorMessage!, textAlign: TextAlign.center),
            ),
            Center(
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ),
          ],
        ),
      );
    }

    if (state.pokemon.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            const Icon(Icons.search_off, size: 44),
            const SizedBox(height: 12),
            Center(
              child: Text(
                state.selectedType == null
                    ? 'No Pokémon to show.'
                    : 'No ${_capitalize(state.selectedType!)} Pokémon found.',
              ),
            ),
            if (state.selectedType != null)
              Center(
                child: TextButton(
                  onPressed: onClearFilter,
                  child: const Text('Clear type filter'),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 5
              : constraints.maxWidth >= 640
              ? 4
              : constraints.maxWidth >= 440
              ? 3
              : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.78,
            ),
            itemCount: state.pokemon.length,
            itemBuilder: (context, index) {
              final pokemon = state.pokemon[index];
              return PokemonCard(
                pokemon: pokemon,
                nickname: state.nicknames[pokemon.id],
                isFavorite: state.favorites.contains(pokemon.id),
                onToggleFavorite: () => onToggleFavorite(pokemon),
                onEditNickname: () => onEditNickname(pokemon),
                onShowDetails: () => onShowDetails(pokemon),
              );
            },
          );
        },
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      child: ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          tooltip: 'Retry loading Pokémon',
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

class _NicknameDialog extends StatefulWidget {
  const _NicknameDialog({
    required this.pokemon,
    required this.currentNickname,
  });

  final Pokemon pokemon;
  final String? currentNickname;

  @override
  State<_NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<_NicknameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nickname for ${_capitalize(widget.pokemon.name)}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Nickname',
          hintText: 'Enter a custom nickname',
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (widget.currentNickname != null)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: const Text('Remove'),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _PokemonDetailsView extends StatelessWidget {
  const _PokemonDetailsView({required this.pokemon, required this.details});

  final Pokemon pokemon;
  final PokemonDetails details;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _capitalize(pokemon.name),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text('#${pokemon.id.toString().padLeft(3, '0')}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: details.types.map((type) => Chip(label: Text(_capitalize(type)))).toList(),
          ),
          Text('Height: ${details.height / 10} m'),
          Text('Weight: ${details.weight / 10} kg'),
          const SizedBox(height: 8),
          Text('Base stats', style: Theme.of(context).textTheme.titleMedium),
          for (final stat in details.stats.entries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_capitalize(stat.key.replaceAll('-', ' '))),
              trailing: Text('${stat.value}'),
            ),
        ],
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : '${value[0].toUpperCase()}${value.substring(1)}';

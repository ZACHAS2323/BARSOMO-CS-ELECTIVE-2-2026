import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pokemon_repository.dart';
import '../models/pokemon.dart';

final pokedexControllerProvider =
    NotifierProvider<PokedexController, PokedexState>(PokedexController.new);

class PokedexState {
  const PokedexState({
    this.isLoading = true,
    this.pokemon = const [],
    this.knownPokemonById = const {},
    this.favorites = const {},
    this.nicknames = const {},
    this.selectedType,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Pokemon> pokemon;
  final Map<int, Pokemon> knownPokemonById;
  final Set<int> favorites;
  final Map<int, String> nicknames;
  final String? selectedType;
  final String? errorMessage;

  PokedexState copyWith({
    bool? isLoading,
    List<Pokemon>? pokemon,
    Map<int, Pokemon>? knownPokemonById,
    Set<int>? favorites,
    Map<int, String>? nicknames,
    String? selectedType,
    bool clearSelectedType = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PokedexState(
      isLoading: isLoading ?? this.isLoading,
      pokemon: pokemon ?? this.pokemon,
      knownPokemonById: knownPokemonById ?? this.knownPokemonById,
      favorites: favorites ?? this.favorites,
      nicknames: nicknames ?? this.nicknames,
      selectedType: clearSelectedType ? null : selectedType ?? this.selectedType,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class PokedexController extends Notifier<PokedexState> {
  late PokemonRepository _repository;
  int _requestNumber = 0;

  @override
  PokedexState build() {
    _repository = ref.watch(pokemonRepositoryProvider);
    Future<void>.microtask(fetchPokemon);
    return const PokedexState();
  }

  Future<void> fetchPokemon() async {
    final requestNumber = ++_requestNumber;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final pokemon = await _repository.fetchPokemon(type: state.selectedType);
      if (requestNumber != _requestNumber) return;

      final knownPokemon = <int, Pokemon>{
        ...state.knownPokemonById,
        for (final entry in pokemon) entry.id: entry,
      };
      state = state.copyWith(
        isLoading: false,
        pokemon: pokemon,
        knownPokemonById: knownPokemon,
        clearErrorMessage: true,
      );
    } catch (error) {
      if (requestNumber != _requestNumber) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load Pokémon. $error',
      );
    }
  }

  Future<void> setTypeFilter(String? type) async {
    state = state.copyWith(
      selectedType: type,
      clearSelectedType: type == null,
      clearErrorMessage: true,
    );
    await fetchPokemon();
  }

  void toggleFavorite(Pokemon pokemon) {
    final favorites = {...state.favorites};
    if (!favorites.add(pokemon.id)) {
      favorites.remove(pokemon.id);
    }
    state = state.copyWith(
      favorites: favorites,
      knownPokemonById: {...state.knownPokemonById, pokemon.id: pokemon},
    );
  }

  void setNickname(int pokemonId, String nickname) {
    final nicknames = {...state.nicknames};
    final trimmedNickname = nickname.trim();
    if (trimmedNickname.isEmpty) {
      nicknames.remove(pokemonId);
    } else {
      nicknames[pokemonId] = trimmedNickname;
    }
    state = state.copyWith(nicknames: nicknames);
  }
}

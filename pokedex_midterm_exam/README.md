# Pokédex Midterm Exam

A Flutter Pokédex that uses Riverpod to manage Pokémon loading, favorites,
nicknames, and type filtering with data from the PokéAPI.

## Run

From this directory:

```powershell
flutter pub get
flutter run
```

## Features

- Loads the first 151 Pokémon from the PokéAPI and supports pull-to-refresh.
- Shows loading, empty, and error states, with a retry action when a request
  fails.
- Filters against the PokéAPI's actual Pokémon type endpoint.
- Lets you add or remove favorites from cards and from the collapsible
  favorites panel.
- Lets you save, edit, and remove nicknames while retaining the original name.
- Opens a Pokémon detail sheet with its actual types, height, weight, and stats.

Favorites and nicknames are held in Riverpod app state for the current session.

# Pokédex Starter

This project displays Pokémon from the PokéAPI in a simple, interactive card layout.

## Files included

- `index.html` – page structure and navigation buttons
- `styles.css` – dark Pokédex design
- `script.js` – fetches data from PokéAPI and renders Pokémon cards

## How to run

1. Open the project folder in VS Code.
2. Start a local web server.
3. Open `http://localhost:8000` in the browser.

### Example command

```bash
cd "c:/Users/Zach/Desktop/new_project"
python -m http.server 8000
```

## Features

- Loads the first page of Pokémon from the PokéAPI
- Shows numbered cards for each Pokémon
- Includes previous and next page controls
- Falls back to the provided PokéAPI sample data if the request fails

## Customize

- Change the color palette in `styles.css`
- Update the layout or content in `index.html`
- Expand the app by adding Pokémon details, search, or filters in `script.js`

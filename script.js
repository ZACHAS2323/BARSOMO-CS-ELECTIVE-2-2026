const pokemonList = document.getElementById('pokemon-list');
const statusText = document.getElementById('status');
const prevButton = document.getElementById('prev-btn');
const nextButton = document.getElementById('next-btn');
const searchInput = document.getElementById('search-input');
const detailPanel = document.getElementById('pokemon-detail');

const fallbackData = {
  count: 1351,
  next: 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
  previous: null,
  results: [
    { name: 'bulbasaur', url: 'https://pokeapi.co/api/v2/pokemon/1/' },
    { name: 'ivysaur', url: 'https://pokeapi.co/api/v2/pokemon/2/' },
    { name: 'venusaur', url: 'https://pokeapi.co/api/v2/pokemon/3/' },
    { name: 'charmander', url: 'https://pokeapi.co/api/v2/pokemon/4/' },
    { name: 'charmeleon', url: 'https://pokeapi.co/api/v2/pokemon/5/' },
    { name: 'charizard', url: 'https://pokeapi.co/api/v2/pokemon/6/' },
    { name: 'squirtle', url: 'https://pokeapi.co/api/v2/pokemon/7/' },
    { name: 'wartortle', url: 'https://pokeapi.co/api/v2/pokemon/8/' },
    { name: 'blastoise', url: 'https://pokeapi.co/api/v2/pokemon/9/' },
    { name: 'caterpie', url: 'https://pokeapi.co/api/v2/pokemon/10/' },
    { name: 'metapod', url: 'https://pokeapi.co/api/v2/pokemon/11/' },
    { name: 'butterfree', url: 'https://pokeapi.co/api/v2/pokemon/12/' },
    { name: 'weedle', url: 'https://pokeapi.co/api/v2/pokemon/13/' },
    { name: 'kakuna', url: 'https://pokeapi.co/api/v2/pokemon/14/' },
    { name: 'beedrill', url: 'https://pokeapi.co/api/v2/pokemon/15/' },
    { name: 'pidgey', url: 'https://pokeapi.co/api/v2/pokemon/16/' },
    { name: 'pidgeotto', url: 'https://pokeapi.co/api/v2/pokemon/17/' },
    { name: 'pidgeot', url: 'https://pokeapi.co/api/v2/pokemon/18/' },
    { name: 'rattata', url: 'https://pokeapi.co/api/v2/pokemon/19/' },
    { name: 'raticate', url: 'https://pokeapi.co/api/v2/pokemon/20/' }
  ]
};

let nextUrl = null;
let previousUrl = null;
let currentPageResults = [];

function formatPokemonName(name) {
  return name.charAt(0).toUpperCase() + name.slice(1);
}

function getPokemonId(url) {
  const match = url.match(/\/pokemon\/(\d+)\//);
  return match ? match[1] : '—';
}

function renderPokemon(data) {
  pokemonList.innerHTML = '';

  const query = searchInput.value.trim().toLowerCase();
  const filtered = data.filter((pokemon) => pokemon.name.toLowerCase().includes(query));

  if (!filtered.length) {
    const emptyState = document.createElement('li');
    emptyState.className = 'empty-state';
    emptyState.textContent = 'No Pokémon match your search.';
    pokemonList.appendChild(emptyState);
    return;
  }

  filtered.forEach((pokemon) => {
    const item = document.createElement('button');
    item.type = 'button';
    item.className = 'pokemon-item';

    const id = getPokemonId(pokemon.url);
    item.addEventListener('click', () => showPokemonDetail(pokemon));

    const image = document.createElement('img');
    image.src = `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png`;
    image.alt = `${pokemon.name} sprite`;
    image.loading = 'lazy';

    const number = document.createElement('span');
    number.className = 'pokemon-number';
    number.textContent = `#${id}`;

    const name = document.createElement('span');
    name.className = 'pokemon-name';
    name.textContent = formatPokemonName(pokemon.name);

    item.append(image, number, name);
    pokemonList.appendChild(item);
  });
}

function updateControls() {
  prevButton.disabled = !previousUrl;
  nextButton.disabled = !nextUrl;
}

function showPokemonDetail(pokemon) {
  const id = getPokemonId(pokemon.url);
  statusText.textContent = `Loading ${formatPokemonName(pokemon.name)}...`;

  fetch(`https://pokeapi.co/api/v2/pokemon/${id}`)
    .then((response) => {
      if (!response.ok) {
        throw new Error('Could not load Pokémon detail');
      }
      return response.json();
    })
    .then((detail) => {
      const types = detail.types.map((entry) => formatPokemonName(entry.type.name)).join(', ');
      const stats = detail.stats
        .map((entry) => `${formatPokemonName(entry.stat.name)}: ${entry.base_stat}`)
        .join(' • ');

      detailPanel.hidden = false;
      detailPanel.innerHTML = `
        <div class="detail-content">
          <img src="https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${id}.png" alt="${detail.name}" />
          <div class="detail-meta">
            <h2 class="detail-name">${formatPokemonName(detail.name)}</h2>
            <div class="detail-types">Type: ${types}</div>
            <div class="detail-stats">Height: ${detail.height / 10} m • Weight: ${detail.weight / 10} kg</div>
            <div class="detail-stats">Stats: ${stats}</div>
          </div>
        </div>
      `;

      statusText.textContent = `Showing ${formatPokemonName(detail.name)} details`;
    })
    .catch(() => {
      detailPanel.hidden = false;
      detailPanel.innerHTML = `
        <div class="detail-content">
          <div class="detail-meta">
            <h2 class="detail-name">${formatPokemonName(pokemon.name)}</h2>
            <div class="detail-types">Details are unavailable right now.</div>
          </div>
        </div>
      `;
      statusText.textContent = 'Unable to load full Pokémon details';
    });
}

function loadPokemon(url = 'https://pokeapi.co/api/v2/pokemon?limit=20') {
  statusText.textContent = 'Loading Pokémon...';
  detailPanel.hidden = true;

  fetch(url)
    .then((response) => {
      if (!response.ok) {
        throw new Error('Failed to fetch Pokémon data');
      }
      return response.json();
    })
    .then((data) => {
      currentPageResults = data.results;
      renderPokemon(data.results);
      previousUrl = data.previous;
      nextUrl = data.next;
      updateControls();
      statusText.textContent = `Showing ${data.results.length} of ${data.count} Pokémon`;
    })
    .catch(() => {
      currentPageResults = fallbackData.results;
      renderPokemon(fallbackData.results);
      previousUrl = fallbackData.previous;
      nextUrl = fallbackData.next;
      updateControls();
      statusText.textContent = 'Using fallback PokéAPI sample data';
    });
}

searchInput.addEventListener('input', () => {
  renderPokemon(currentPageResults);
});

prevButton.addEventListener('click', () => {
  if (previousUrl) {
    loadPokemon(previousUrl);
  }
});

nextButton.addEventListener('click', () => {
  if (nextUrl) {
    loadPokemon(nextUrl);
  }
});

loadPokemon();

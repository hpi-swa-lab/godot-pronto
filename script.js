const USERNAME = "hpi-swa-lab";
const REPOSITORY = "godot-pronto";
const BRANCH = "gh-pages";

requestGames();

/**
 * Requests the branch where the games are deployed in order to display the games that are present.
 */
async function requestGames() {
  try {
    const response = await fetch(`https://api.github.com/repos/${USERNAME}/${REPOSITORY}/git/trees/${BRANCH}`);
    if (response.ok) {
      const json = await response.json();
      const files = json.tree;
      const promises = files.filter(file => file.type === "tree").map(file => loadGameData(file.path));
      const gameDataArray = await Promise.all(promises);
      createGames(gameDataArray);
    } else {
      console.error("ERROR: Cannot receive the list of games. Error message:", response.statusText);
    }
  } catch (error) {
    console.error("ERROR: An error occurred while fetching the games list.", error);
  }
}

/**
 * Loads the game_info.json file for the game and returns the game data.
 * If no game_info.json is provided, it will return an object with title and playLink.
 */
async function loadGameData(gamePath) {
  try {
    const response = await fetch(`https://raw.githubusercontent.com/${USERNAME}/${REPOSITORY}/${BRANCH}/${gamePath}/game_info.json`);
    if (response.ok) {
      const gameInfo = await response.json();
      if (!gameInfo.title) {
        console.warn(`JSON for game ${gamePath} is not valid because it does not contain a title:`, gameInfo);
        return {
          title: gamePath,
          playLink: gamePath,
        };
      }
      if (!gameInfo.playLink) {
        gameInfo.playLink = gamePath;
      }
      return gameInfo;
    } else {
      console.warn(`No game info found for ${gamePath}. Please check if you have provided a "game_info.json" file.`);
      return {
        title: gamePath,
        playLink: gamePath,
      };
    }
  } catch (error) {
    console.error(`ERROR: An error occurred while fetching game data for ${gamePath}.`, error);
    return {
      title: gamePath,
      playLink: gamePath,
    };
  }
}

/**
 * Displays games based on the provided array of game data, sorted by title.
 */
function createGames(games) {
  const sortedGames = games.sort((a, b) => a.title.localeCompare(b.title));
  sortedGames.forEach(gameInfo => createGame(gameInfo));
}

/**
 * Displays a game based on the provided gameInfo JSON. Following keys are supported:
 * - title - The title of the game that is displayed
 * - playLink - The parent folder of the index.html of the game.
 * - description (optional) - A description of the game
 * - authors (optional) - The authors of the game.
 * - thumbnailType (optional) - Path to the image that represents the game
 */
function createGame(gameInfo) {
  const gamesContainer = document.getElementById('gamesContainer');

  const gameElement = document.createElement('div');
  gameElement.className = 'game';

  if (gameInfo.thumbnailType) {
    const thumbnail = document.createElement('img');
    thumbnail.src = `https://raw.githubusercontent.com/${USERNAME}/${REPOSITORY}/${BRANCH}/i6w1-jf-geometry-dash/thumbnail.${gameInfo.thumbnailType}`;
    thumbnail.alt = gameInfo.title;
    gameElement.appendChild(thumbnail);
  }

  const title = document.createElement('h2');
  title.textContent = gameInfo.title;
  gameElement.appendChild(title);

  if (gameInfo.description) {
    const description = document.createElement('p');
    description.textContent = gameInfo.description;
    gameElement.appendChild(description);
  }

  const playLink = document.createElement('a');
  playLink.href = gameInfo.playLink;
  playLink.textContent = 'Play Now';
  gameElement.appendChild(playLink);

  gamesContainer.appendChild(gameElement);
}

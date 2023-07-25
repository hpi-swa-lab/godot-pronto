const USERNAME = "hpi-swa-lab";
const REPOSITORY = "godot-pronto";
const BRANCH = "gh-pages";

requestGames();

/**
 * Requests the branch where the games are deployed in order to display the games that are present.
 */
function requestGames() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      const response = JSON.parse(this.responseText);
      const files = response.tree;
      files.filter(file => file.type == "tree").forEach(file => loadGameData(file.path));
    }
  };
  xmlhttp.open("GET", `https://api.github.com/repos/${USERNAME}/${REPOSITORY}/git/trees/${BRANCH}`, true);
  xmlhttp.send();
}

/**
 * Loads the game_info.json file for the game and creates a container for the game.
 * If no game_info.json is provided, it will still list the game while also printing a warning in the console.
 */
function loadGameData(gamePath) {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState !== 4) return;
    const gameInfo = {
      title: gamePath,
      // playLink: gamePath
    }
    if (this.status == 200) {
      const json = JSON.parse(this.responseText);
      if (json.title) { // Check if the json contains the attribute title. Otherwise it cannot be valid
        gameInfo = json;
      } else {
        console.warn(`JSON for game ${gamePath} is not valid because it does not contain a title:`, json);
      }
    } else {
      console.warn(`No game info found for ${gamePath}. Please check if you have provided a "game_info.json" file.`)
    }
    if (!gameInfo.playLink) { // Make sure playLink is set.
      gameInfo.playLink = gamePath;
    }
    createGame(gameInfo);
  };
  xmlhttp.open("GET", `https://raw.githubusercontent.com/${USERNAME}/${REPOSITORY}/${BRANCH}/${gamePath}/game_info.json`, true);
  xmlhttp.send();
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

  if(gameInfo.thumbnailType) {
    const thumbnail = document.createElement('img');
    thumbnail.src = `https://raw.githubusercontent.com/${USERNAME}/${REPOSITORY}/${BRANCH}/i6w1-jf-geometry-dash/thumbnail.${thumbnailType}`;
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
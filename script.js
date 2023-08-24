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
 * If no game_info.json is provided, it will return an object with title and path.
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
          path: gamePath,
        };
      }
      if (!gameInfo.path) {
        gameInfo.path = gamePath;
      }
      return gameInfo;
    } else {
      console.warn(`No game info found for ${gamePath}. Please check if you have provided a "game_info.json" file.`);
      return {
        title: gamePath,
        path: gamePath,
      };
    }
  } catch (error) {
    console.error(`ERROR: An error occurred while fetching game data for ${gamePath}.`, error);
    return {
      title: gamePath,
      path: gamePath,
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
 * - path - The parent folder of the index.html of the game.
 * - description (optional) - A description of the game
 * - authors (optional) - The authors of the game.
 */
function createGame(gameInfo) {
  const gamesContainer = document.getElementById('gamesContainer');

  const gameElement = document.createElement('div');
  gameElement.className = 'game';

  // Create the thumbnail image
  const thumbnailContainer = document.createElement('div');
  thumbnailContainer.className = 'thumbnail-container';
  gameElement.appendChild(thumbnailContainer);
  const thumbnail = document.createElement('img');
  thumbnail.src = `https://raw.githubusercontent.com/${USERNAME}/${REPOSITORY}/${BRANCH}/${gameInfo.path}/thumbnail.png`;
  thumbnail.alt = gameInfo.title;
  thumbnailContainer.appendChild(thumbnail);

  // create the header
  const header = document.createElement('div');
  header.className = 'header';
  gameElement.appendChild(header);
  const title = document.createElement('h2');
  title.textContent = gameInfo.title;
  header.appendChild(title);

  // Create the author tags if they exist in the provided data
  if (gameInfo.authors && gameInfo.authors.length > 0) {
    const authorsContainer = document.createElement('div');
    authorsContainer.className = 'authors-container';

    gameInfo.authors.forEach(author => {
      const authorTag = document.createElement('span');
      authorTag.className = 'author-tag';
      authorTag.textContent = author;
      authorTag.title = 'This person is an author of this game'
      authorsContainer.appendChild(authorTag);
    });

    header.appendChild(authorsContainer);
  }

  // Create the description of the game
  if (gameInfo.description) {
    const description = document.createElement('p');
    description.textContent = gameInfo.description;
    gameElement.appendChild(description);
  }

  // Create the footer with the play button
  const footer = document.createElement('div');
  footer.className = 'footer';
  gameElement.appendChild(footer);

  const shareLink = document.createElement('a');
  footer.appendChild(shareLink);
  shareLink.addEventListener("click", () => copyShareLink(gameInfo.path));
  shareLink.title = "Copy link to this game";
  const shareIcon = document.createElement('i');
  shareIcon.className = 'fa fa-share-alt';
  shareLink.appendChild(shareIcon);

  const playLink = document.createElement('a');
  playLink.href = gameInfo.path;
  playLink.className = 'btn-play';
  const playIcon = document.createElement('i');
  playIcon.className = 'fa fa-play';
  playLink.appendChild(playIcon);
  const buttonText = document.createElement('span');
  buttonText.innerText = "Play Now";
  playLink.appendChild(buttonText);
  footer.appendChild(playLink);

  gamesContainer.appendChild(gameElement);
}

function copyShareLink(link) {
  const copyText = `${window.location.href}${link}`;
  navigator.clipboard.writeText(copyText);
  if (navigator.share) {
    navigator.share({ url: copyText});
  }
}

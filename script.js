requestGames("hpi-swa-lab");

function requestGames(username, repository = "godot-pronto", branch = "gh-pages") {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      const response = JSON.parse(this.responseText);
      let files = response.tree;
      files = files.filter(file => file.type == "tree");
      const games = files.map(file => {
        return {
          "title": file.path,
          "playLink": file.path
        }
      });
      loadGames(games);
    }
  };
  xmlhttp.open("GET", `https://api.github.com/repos/${username}/${repository}/git/trees/${branch}`, true);
  xmlhttp.send();
}

/**
 * Fetches the local games.json file. This file should contain an array with the games that each have following fields:
 * - title - The title of the game that is displayed
 * - playLink - The link to the index.html of the game
 *  - description (optional) - A description of the game
 *  - thumbnail (optional) - Path to the image that represents the game
 */
function loadGames(gameList) {
  const gamesContainer = document.getElementById('gamesContainer');

  gameList.forEach(game => {
    const gameElement = document.createElement('div');
    gameElement.className = 'game';

    if(game.thumbnail) {
      const thumbnail = document.createElement('img');
      thumbnail.src = game.thumbnail;
      thumbnail.alt = game.title;
      gameElement.appendChild(thumbnail);
    }

    const title = document.createElement('h2');
    title.textContent = game.title;
    gameElement.appendChild(title);

    if (game.description) {
      const description = document.createElement('p');
      description.textContent = game.description;
      gameElement.appendChild(description);
    }

    const playLink = document.createElement('a');
    playLink.href = game.playLink;
    playLink.textContent = 'Play Now';
    gameElement.appendChild(playLink);

    gamesContainer.appendChild(gameElement);
  });
}
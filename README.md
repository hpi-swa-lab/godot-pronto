# Prototype Library

This is the place where all deployed prototypes are collected.

Use the workflow from your development branch to build and deploy your game automatically.

DO NOT ADD FILES HERE MANUALLY UNLESS YOU KNOW WHAT YOU ARE DOING!

## How this works

The `index.html` renders our Prototype-Library which is an overview of all the available games. It reads this game via an API call to github that checks for all folders that exist in this branch and creates a game-container for them. For each game the script then tries to read the `game_info.json` file from the corresponding folder to display detailed information about the game. Currently we support:

- `title` - The display title of the game in the Library
- `description` - The description of the game that is displayed.
- `authors` - An array of the names of the authors that worked on this game.
- `thumbnailType` - The file ending of the thumbnail file. Supported are `png` and `jpg`.
- `path` (don't change this unless you know what you are doing) - The relative path to the game's `index.html`. By default this is the folder name where the game is in.

If you want your game to show a thumbnail you need to provide an image called `thumbnail.png` (or `.jpg`) in the folder of your game. This will automatically be copied to the build of your game in the workflow.

A template for your `game_info.json` may look like this:

```json
{
  "title": "My Game",
  "description": "The description of my game that is displayed in the overview.",
  "authors": ["Developer 1", "Developer 2"],
  "thumbnailType": "png"
}
```

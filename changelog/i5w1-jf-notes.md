# Move planning game

![Planning our game on a whiteboard](i5w1-jf-concept.png)

We started this week by planning the basic game mechanics on a whiteboard. This way we also found some insights regarding UI design and abilities for the players.

## How we utilized pronto nodes

We used the Healthbar as actual healtch display for the players but also for displaying the number of moves a player has already planned (blue bar below the healthbar).

## Problems

### Duplicating Code-Behavior

We had a lot of situations where we basically had to copy many nodes for player 2. However, when copying a code-behavior and then changing its code (from `player1` to `player2`) we changed both the original and the copied node because they somehow share the expression. This meant for us that we needed to create each node invidiually and basically had to just copy paste the content.

### Key Nodes

For our inputs we have 6 keys per player, however we only want to trigger the same connection on each key press. Currently we had to create 6 key but we thought that one may want to have a node that accepts certain keys and offers the same triggers as the key note while also specifying which of the selected keys triggered.

### Issues with Healthbar

We had a problem with the HealthBar where it resets the current health to max on godot startup. We found the problem for this and want to fix it in the next week for master.

### Value

When changing the `min` or `max` of the value, the current value is not updated if it is outside these bounds.

### Connection Window

The text inputs for the parameters do not scale anymore. This means that for some input you cannot read it in the window which is annoying. Even moving the cursor further doesn't scroll the window. Resizing the window does nothing either.

![Text in the parameter field is not readable](i5w1-jf-ProblemWindow.png)

## User study

We also conducted a user study this week. For simplicity we also noted down the basic commands and goal of the game to present to the users.

### Goal

You have to schedule a number of actions for your character to execute. Both players choose their moves simultaniously but without knowledge of the opponents move. Then both moves are executed secuentually at the same time. Your goal is to kill the enemy player with your attacks. The game can also end in a draw.

### Controls

There are 6 actions you can choose from:

* Moving one tile to one of four directions.
* `Cross-Attack` that hits the enemy if they are in the same row or column as you.
* `Box-Attack` that deals damage to enemies that are adjacent to you (on one of the `8` fields surrounding your field) and a litte damage to enemies that are a bit further away.

```
Cross-Attack:
....#...
....#...
....#...
####X###
....#...
....#...
....#...
....#...
```

```
Box-Attack:
........   
...ooo..
..o###o.
..o#X#o.
..o###o.
...ooo..
........
........
```

#### Player 1

You move with `WASD`. You can use the `Cross-Attack` with `Q` and the `Box-Attack` with `E`.

#### Player 2

You move with `IJKL`. You can use the `Cross-Attack` with `U` and the `Box-Attack` with `O`.

### Learnings

We found out that it is interesting to not only schedule the actions in a `FiFo`-matter (Queue) but also have some rounds where they are executed in the inverted order (`LiFo`, Stack). This made planning several moves ahead even more difficult because they need to be added in a different order.

It also got a bit borring to always plan just 3 moves ahead. This is why we randomized the number of moves to plan each round.

Since our game is completely fair we also had many games that ended in a draw. This is why we decided to add some kind of randomness to our game in form of a heal potion that randomly drops on a tile, healing a player for a certain amount.

## Improvements for next week

We also thought about more improvements for our features from last week:

* **Healthbar**: Fix issue where `current` is set to `max` on godot start.
* **Healthbar**: Use gradient instead of Array of colors.
* **Placeholder**: Merge with `PlaceholderShape`.
* **Placeholder**: Recoloring options for the used sprite.
* **Placeholder**: Add "Emoji-API" as a fast way of finding sprites.
* **Select-Behavior**: Think about adding a new behavior for drag-to-select (or mayber even drag-and-drop) options (like we used in our last weeks prototype).
* **Key**: Add option to show the key-node in the game with a label to describe the controls of the game.
* **Value**: Fix out of bounds when changinig `min` or `max`.
* **Code**: Remove Label from Code-Behavior and use the name from the object-tree instead

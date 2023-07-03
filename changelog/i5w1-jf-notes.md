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

## User testing

We also conducted a user study this week. For simplicity we also noted down the basic commands and goal of the game to present to the users.

### Goal

You have to schedule a number of actions for your character to execute. Both players choose their moves simultaniously but without knowledge of the opponents move. Then both moves are executed secuentually at the same time. Your goal is to kill the enemy player with your attacks. The game can also end in a draw.

### Controls

There are 6 actions you can choose from:

* Moving one tile to one of four directions.
* `Cross-Attack` that hits the enemy if they are in the same row or column as you.
* `Box-Attack` that deals damage to enemies that are adjacent to you (on one of the `8` fields surrounding your field) and a litte damage to enemies that are within 2 tiles around you (`16` additional fields).

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
..ooooo.
..o###o.
..o#X#o.
..o###o.
..ooooo.
........
........
```

#### Player 1

You move with `WASD`. You can use the `Cross-Attack` with `Q` and the `Box-Attack` with `E`.

#### Player 2

You move with `Arrow Keys`. You can use the `Cross-Attack` with `"."` and the `Box-Attack` with `"-"`.

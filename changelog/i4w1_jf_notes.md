# Week 1 notes

## Problems

Our biggest problem this week was the **instability of Pronto** itself. We had situations where godot crashed after changing certain connections. However, the concrete reasons for those crashes need to be further investigated in order to fix them.

Since Pronto has no functionality regarding NavigationAgents/-Meshes/-Regions, etc. it was quiet difficult to get startet with this. For most of our key functionalities of the game we had to use Code because there is no Pronto Behavior yet. We didn't achieve to use NavigationObstacles for the units to go around eachother.

## Pronto-Behaviors we wish we had

- **Health Bar**: It would be nice to have some kind of Health Bar Behavior that would provide an easy way of displaying and changing an objects health. Currently one has to do a lot of code if one wants to change an enemies health and update a healthbar and label with the new label and maybe also remove the element (if the enemy dies).
- **Drag to select**: An easy way to select multiple nodes with dragging of the mouse int oder to move all of them by clicking somewhere at the scene. This could also be used to execute code during runtime on one or multiple nodes. This could be done as part of the `Controls`-Behavior.
- **(Placeholder with )Icons**: Find a simple way to provide an icon for placeholders. Maybe this could be done with some internet search using the `placeholder-label` that the user provides in order to give the user a few example icons that match this label. This would add the convenience of having icons for visualization purposes without costing the programmer any additional time of finding such an icon himself.

### Additional functionality of Behaviors we wish we had

- **k-nearest-neighbors-of-group**: It would be helpful to get the k (in our case k = 1) nearest neighbors of a node that are part of a certain group (`enemy`). This could be part of the `SceneRoot`-Behavior.
- **Visibility-toggle for Prototyping UI**: We would like to have an easy way to minimize the Prototyping UI during runtime so it doesn't take away an important part of the screen
- **Navigation-Behvaior**: A behavior that encapsulates a `NavigationAgent2D` for simpler usage in future prototypes.
- **2nd iteration of SceneRoot / GroupNode (new Behavior)**: With regards to the feedback from last week we also thought about reworking the SceneRoot or adding a new GroupNode Behavior that simplifies the usage and interaction with elements of a specific group in Pronto.

## Feedback from user study

We asked a few different people with different background (some ITSE students, some people that play computer games and others that dont play computer games). Some of them also participated in multiple runs (see table below). Their feedback can be summerized by the following:

1. Visuals are very important for understanding the game and its mechanics (so we added them after the first run) -> Further tests proofed that this was indeed very helpful.
2. Controlling the own units is feeling weird because you dont know what units you have selected and if you are in the "set target mode" or not.
3. Behavior of attacking seems to be not working that reliable.
4. Units don't go around each other so sometimes they form a long line and only a few of them attack. It would expect them to go around each other.

### Overview of runs

| |Amount|
|-|-|
| Wins | 8 |
| Losses | 3 |

We also noticed different strategies: In some runs the user was very focussed on defending the own base and took some time before attacking themself. Other users used a more aggressive strategy and tried to send some units along a longer path to sneak up on the enemy and finish the game way faster (those were mainly the people that also play other computer games).

### Changes between runs

After a few runs we tweeked following parameters to make the game harder / balance it:

1. Decrease range of knights and zombies to be more "melee" (from 100 to 50).
2. Decrease enemy spawn time from 3 to 2.5 s (at least we thought so, however we discovered later on, that there was a bug in the PrototypingUI that reset this value to 3 on startup so it basically was unchanged)
3. Decrease start money from 20 to 0.

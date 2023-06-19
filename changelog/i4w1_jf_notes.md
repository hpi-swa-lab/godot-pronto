# Week 1 notes

## Problems

Our biggest problem this week was the instability of Pronto itself. We had situations where godot crashed after changing certain connections. However, the concrete reasons for those crashes need to be further investigated in order to fix them.

Since Pronto has no functionality regarding NavigationAgents/-Meshes/-Regions, etc. it was quiet difficult to get startet with this. For most of our key functionalities of the game we had to use Code because there is no Pronto Behavior yet.

## Pronto-Behaviors we wish we had

- **Health Bar**: It would be nice to have some kind of Health Bar Behavior that would provide an easy way of displaying and changing an objects health. Currently one has to do a lot of code if one wants to change an enemies health and update a healthbar and label with the new label and maybe also remove the element (if the enemy dies).
- **Drag to select**: An easy way to select multiple nodes with dragging of the mouse int oder to move all of them by clicking somewhere at the scene. This could also be used to execute code during runtime on one or multiple nodes. This could be done as part of the `Controls`-Behavior.

## Additional functionality of Behaviors we wish we had

- **k-nearest-neighbors-of-group**: It would be helpful to get the k (in our case k = 1) nearest neighbors of a node that are part of a certain group (`enemy`). This could be part of the `SceneRoot`-Behavior.
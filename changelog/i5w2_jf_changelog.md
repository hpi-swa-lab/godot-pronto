# Iteration 5 Week 2 - Julian & Finn

## Code-Behavior

We removed the label from the Code-Behavior and use its name from the SceneTree instead. We found ourself labeling nodes twice (once in the tree and then again in the label) so we decided to change this.

Also we added comments to the Behavior.

## HealthBar-Behavior

We replaced the `progress_colors` array with a `progress_gradient` as suggested in the meeting.

We also fixed the problem described by Luc, where the current health would be set to 100 on game start even though max is higher. The problem occured because of the ordering of the variables inside the script: By placing current above max, when the game starts it tries to set current to a value (like 400) when max is still on its default value of 100, so current is clamped to 100. Then max gets set to its value of 400 but current is not updated anymore. This caused the issue of wrong health at game start which is now fixed by setting current health after max health.

Additionally we fixed the displaying of outgoing lines from the HealthBar and Placeholders.

As already mentioned in the Slack channel, the documentation comments for the inspector are broken for everything comming after the first exported category. However, this seems to be a godot problem that we cannot fix easily but we still want to mention it here before we forget about this.

## Placeholder-Behavior

### Sprite Library

We want to enable the user to quickly select and apply fitting sprite images to the Placeholder. For the textures we used the Kenney 1-Bit Pack ([https://kenney.nl/assets/1-bit-pack](https://kenney.nl/assets/1-bit-pack)). 

To allow for displaying different suggestions and a quick selection we want a visual representation of all textures ideally combined with an option for filtering.  We used the Editor-Icon Previewer Plugin as an inspiration and basis to start from, because it already has a nice visual representation and other features like a preview, scaling and a search bar. ![image](i5w2_jf_editor_icon_previewer.png)

Similar to the expressions, we created a new `EditorInspectorPlugin` for the `PlaceholderBehavior` for selection and applying tiles from our tilemap as textures for the sprite. ![image](i5w2_jf_sprite_window.png)

The searchbar can be used for filtering the textures. Currently only the following categories are available:
- Characters
- Accessories
- Nature
- Cards
### Modulate Color

We added a new color option to modulate the color of the sprite.
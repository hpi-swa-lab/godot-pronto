# Iteration 5 Week 2 - Julian & Finn

## Code-Behavior

We removed the label from the Code-Behavior and use its name from the SceneTree instead. We found ourself labeling nodes twice (once in the tree and then again in the label) so we decided to change this.

Also we added comments to the Behavior.

## HealthBar-Behavior

We replaced the `progress_colors` array with a `progress_gradient` as suggested in the meeting.

As already mentioned in the Slack channel, the documentation comments for the inspector are broken for everything comming after the first exported category. However, this seems to be a godot problem that we cannot fix easily but we still want to mention it here before we forget about this.

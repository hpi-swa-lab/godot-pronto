# Iteration 5 Week 2 - Julian & Finn

## Code-Behavior

We removed the label from the Code-Behavior and use its name from the SceneTree instead. We found ourself labeling nodes twice (once in the tree and then again in the label) so we decided to change this.

Also we added comments to the Behavior.

## HealthBar-Behavior

We replaced the `progress_colors` array with a `progress_gradient` as suggested in the meeting.

We also fixed the problem described by Luc, where the current health would be set to 100 on game start even though max is higher. The problem occured because of the ordering of the variables inside the script: By placing current above max, when the game starts it tries to set current to a value (like 400) when max is still on its default value of 100, so current is clamped to 100. Then max gets set to its value of 400 but current is not updated anymore. This caused the issue of wrong health at game start which is now fixed by setting current health after max health.

As already mentioned in the Slack channel, the documentation comments for the inspector are broken for everything comming after the first exported category. However, this seems to be a godot problem that we cannot fix easily but we still want to mention it here before we forget about this.

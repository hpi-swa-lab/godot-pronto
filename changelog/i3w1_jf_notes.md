# I3W1 - Super Mario Snake and other moving obstacles

## What feature did we miss in pronto

1. It would be nice to assign the value of a `Value`-Behavior to things like the `duration_seconds` of the Clock (like `at("ClockDuration")`). This would help with trying out different values for such properties. Maybe it would be best to have the `duration_seconds` as an expression that gets evaluated during runtime if possible.

2. When trying out `Spawners` in a different szene (other than the main szene) it seems to cause some errors.

3. It would be nice for testing different things and executing some code on demand to have a Pronto `Button` that can be clicked and supports the Pronto connections.

## Where did we use code

1. We used code to set the timer durations to the value of the value sliders in order to try out different values by using the `PrototypingUI`.

2. We also used code for the snake to move because we needed to use `_physics_process(delta)` isntead of the `_process(delta)` that the Always-Behavior would provide. Therefore, we had to create custom scripts for these blocks.

## What we liked about Pronto

The `PrototypingUI` made it very easy to test different values with ease. However, improving the behavior to be the panel itself instead of having to add a Container manually would be great for UX.

## Pronto Bugs

We noticed that copying pronto nodes would create images as child-nodes that contain the icon of the behavior. Those images are also rendered when the game is running so they have to be deleted manually. This makes copy-pasting very stressfull, because youu cant see those images in the szene preview (since they are located at the same position as the behavior which renders its own icon).

## Other things we noticed

When resetting the blue platforms we first wanted to freeze them and reset their position to the origin. However, due to the gravity physics they would sometimes execute the physics process after we froze them. This caused the platform to be placed at a completely different position, not visible to the user (since it has fallen below the visible screen).

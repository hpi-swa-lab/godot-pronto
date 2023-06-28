# Changelog Iteration 4 Week 2

## HealthBar - New

Our goal for this behavior was to provide an easy to use way of adding a healthbar to enemies and other objects within the game. We need an easy way to manipulate the health with pronto connections and also have a signal that triggers, when the health drops to `0`.

### Implementation

The new `HealthBar` offers an easy way to display the `current` and `max` health of an object. The current health is clamped to `0` and `max`. If it drops to `0`, the `death` signal is emitted. The current health can be manipulated with following functions:

* `damage(amount)` - Reduces the health by the given amount.
* `heal(amount)` - Heals for the given amount.
* `heal_full()` - Sets the current health to `max`.
* `set_health(value)` - Sets the current health to the given `value`.

Whenever the health value is changed we also emit the `changed(health)` signal.

In addition to the rectangular representation of the healthbar there is also the option to display the current health as a text label. Following display styles are available for this label:

* `None` - No text label is shown.
* `Health` - Health is shown in the format `{current}`.
* `Fraction` - Health is shown in the format `{current}/{max}`.
* `Health` - Health is shown in the format `{100 * current/max} %`.

Last but not least we also added the option to set custom colors for the healthbar depending on the current health value. By default they are as follows:

* `0 % - 20 %`   - Red
* `20 % - 50 %`  - Yellow
* `50 % - 100 %` - Green

## Issues

Currently the outgoing connections of the `HealthBar` are not shown in the editor. The
connections do exit and work, just the arrow representation is missing in the editor. We currently
don't know the source of this problem as no error is thrown then creating connections.
Unfortunately we will not have enough time in this iteration to find a fix for this problem.

## Placeholder - Changes

Out goal for this change was to find an easy solution for adding sprite textures to the placeholder in order to make them more appealing for the user tests. The time overhead of adding a suitable texture should be minimal and the developers should not spend a lot of time searching for the icon they want to use.

Additionally, we also want a way to highlight placeholder, for example if they are selected as part of the users input within the game.

## Implementation

### Sprites

We added a `Sprite` category to the placeholder where the user developer can toggle, wether they want to user a sprite or not. To use a sprite it needs to be selected as the `sprite_texture` where they can easily select an `.svg` or `.png` (or any other supported file format).

### Outline

We also added an `Outline` category to the placeholder. In case of a simple shape as placeholder this just draws another rectangle without a fill above the placeholder. In case of a sprite we use a shader that draws the outline around the sprite.

The visiblity of the outline is controlled by `outline_visible`. The color of the outline can be set in `outline_color` and the width with `outline_width`.

Additionally, for the outline that is created with the shader for the sprites there are 3 options for the method that is used in the shader to create the outline:

* `Circle`
* `Diamond`
* `Square`

These shapes decide the roundness of the corners of the outline with `Circle` being round edges, `Square` being right angles and `Diamond` being less rounded and a bit steeper than `Circle`.

## Not implemented yet

Unfortunately we were unable to find a way to include an asset library into pronto so far. This may be addressed in another sprint.

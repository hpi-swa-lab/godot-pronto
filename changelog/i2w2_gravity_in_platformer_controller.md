# Changelog

## Iteration 2 Week 2

### Gravity in the `PlatformerController`

We removed the `gravity` parameter of the `PlatformerController`. Instead we now leverage the `PhysicsServer2D` by making the gravity settings via Areas which then affect the player when they are inside that area.

This allows a more complex handling of different forces that could influence a player. We can have different gravitational pulls and even emulate other uniform linear forces (e.g. wind) by utilizing areas.

For an example, have  look at `../examples/platformer/platformer_gravity.tscn`.

### Breaking Changes

- `PlatformerController.gravity` does not exist anymore, use areas to have effects on the player instead

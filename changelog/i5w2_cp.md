# Changelog

## i5w2_cp

### New Features

- **New `Drag` Behavior:** Add as a child to any node to make it draggable using the mouse. Through the `button_mask` property, you can choose which mouse buttons can be used for dragging. The behavior emits different signals for hovering (`mouse_entered(pos)`, `mouse_exited(pos)`), drag'n'drop (`picked(pos)`, `dropped(pos, startpos)`), and moving (`dragged(pos, startpos, lastpos)`). Supports different nodes such as character bodies, static bodies, sprites, placeholders, and controls. In particular, physics bodies such as `RigidBody2D` are supported as well (by freezing their physics while being dragged).
  - **Possible future work:** Add support for complex draggable shapes (e.g., by exactly combining areas of children, specifying CollisionShapes, or checking for certain collision layers)

### Bugfixes & Miscellaneous

- Fixes adding of more references in connection window: Generated source code will no longer contain syntax errors. Generated code is updated immediately after adding/editing/deleting more references.

- Avoids losing changes in connection windows when opening a script in the Godot editor by automatically saving the connection at that point.
  - **Possible future work:** Maybe always auto-save all connections?

- Fixes opening of multiple similar connection windows. Opening a connection with the same receiver and signal as another open one will not fail any longer.

# Changelog

## Iteration 2 Week 2

### More Inputs
We extended the ``Controls`` component to utilize mouse inputs using the following events:
* ``mouse_down`` : position and button
* ``mouse_up`` : position, button and duration of holding the button
* ``mouse_move`` : position
* ``mouse_drag`` : position

To quickly get the currently held mouse buttons, you can now also use ``get_held_mouse_buttons()`` in ``Controls``.
In addition, the ``Key`` behavior also reveals the duration of holding a key on the ``just_up`` signal.


### Visual Line
Draw a visual line between two nodes. Automatically updates with movement.

#### Bugs and Problems
Visual lines don't work with during the runtime instanced objects, e.g. spawned objects.
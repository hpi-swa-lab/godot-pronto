# Changelog

## i3w2_cp

### New Features

#### Connections Editing

- **Window-style connections editing:** Connection editors can now be dragged and pinned to the scene. This change intends to make it easier to keep multiple connections with their details such as conditions in the short-term memory, especially for observers during pair programming, and to reduce the cost of re-selecting behaviors.

  Click and drag an editor to move it relatively to the scene. The dragged editor will be placed in front of all overlapping editors. Pin an editor to keep it in the scene after saving the connection by toggling the pin icon in the editor's title bar, or by double-clicking in its background.

- **Disable connections:** To explore different approaches or troubleshoot erroneous connections, connections can now be disabled and reenabled. To disable a connection, untick the checkbox in the connection editor. The enablement is toggled immediately without needing to save the connection. Alternatively, you can quickly disable or enable a connection from the context menu of the connection list. Disabled connections are displayed in gray in the scene and the connections list.

- **Reset connection condition:** After changing the condition of a connection in the editor, you can press the reset icon left to it to reset the condition to the default `true` again.

- **Indication of unsaved changes in connection editor:** The connection editor now displays a yellow dot in its title bar to indicate unsaved changes. The dot is removed when the connection is saved.

- **Highlight connection for hovered editor:** To make it easier to identify the connection in the scene for a connection editor, the corresponding connection is now highlighted when hovering over an editor.

- **Arrowhead for connections:** The direction of connections is now indicated by an arrowhead. We also shortened the arrows a bit to improve readability.

#### Behaviors

- **Default positioning of behaviors:** Revises the default positioning of newly inserted behaviors to honor the shapes of the parent nodes and siblings. The layout strategy has still a lot of room for improvement, e.g., by avoiding collisions with other nodes.
- **Inspect:** Makes the font size customizable through the inspector.
- **Always:** Adds methods `pause()` and `resume()` to disable and enable ticking of the behavior.

### Bug Fixes and Clean-ups

- **Placeholder:** Fixes resizing of rotated placeholder nodes.
- **Inspect:** Fixes evaluation of expressions in editor mode.
- **Connection list:** Avoids outdated connection items in the list by closing the list after selecting an item.

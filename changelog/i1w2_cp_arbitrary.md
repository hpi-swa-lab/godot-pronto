# Changelog

## Iteration 1 Week 2

### New Features

- **Statement connections:** Trigger arbitrary code execution on a signal using the statement mode (52359b584ac778662266fbbc6f60d330303a4c60)
  - In a connection editor, users can now select `<statement(s)>` in place of a method and enter a multiline code expression into the pane. The expression has access to `from` and `to` and is rendered amongst other connections to the target. The code expression is rendered in the connections list. Users can later change a connection between expression and invocation mode. Undo/redo is supported as well.
- Connect behaviors to arbitrary Godot nodes (other than Node2Ds, Node3Ds, and Controls) (49340a5478d96a01a258c4f8a921c6c50e803995)
  - Code can call any method on any node.

### Bugfixes

- Bugfix: Reopened connections editor selects correct method (33352ac63382e2046583fa946d91bf960c23c131)

### Breaking API changes:

- **Connections:**
  - Nodes in connections are no longer restricted to nodes with a `global_position` property but can be any Godot nodes. For accessing the closest position or positional node, use `Utils.closest_parent_with_position()` and `Utils.find_position()`, resp.
  - Connections that are expressions now also expect an optional `to` node.
  - Moved `Utils.print_connection()` to `Connection.print()`.
  - State of `Connection` and `NodeToNodeConfigurator` is refined: new receiver mode (`has_target()`, indicates whether the connection has a target) orthogonal to existing expression mode (`is_expression()`, indicates whether the connection has a code expression instead of calling a method).

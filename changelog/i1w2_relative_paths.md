# Changelog

## Iteration 1 Week 2

### Connections From Spawned Nodes to Static Nodes

Previously, when spawning nodes, the spawner uses its first child as a blueprint. 
When the `spawn` method is called, a copy of the blueprint is made and appended
to the spawner's parent node. This resultet in broken connections that span from
the blueprint to nodes outside the blueprint, as the connections use relative
paths to determine the `to` part.

That has been fixed with this change.

#### Changes

When spawning a node, the spawner spawns a dummy node inside its parent. 
The new instance then gets appended to the dummy node, so that outgoing 
relative paths stay correct.

#### How this affects you

Not at all. Everything should just work

#### Future Work

This does not solve the problem for connections from an outside node
to a blueprint. This still needs to be fixed.

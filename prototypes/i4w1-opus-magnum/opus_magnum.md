# Opus Magnum

"Opus Magnum is a puzzle game where you build machines to transform alchemical reagents into new materials." - GitHub Copilot

## Prototype

In our prototype, we recreated the core mechanics using Pronto:

- The player can spawn atoms, mergers, and robot arms on the desk (through keyboard shortcuts) and arrange them on the desk (through drag and drop).
- For each arm, the player can edit a sequence of instructions such as rotation, grab, and release.
- The player can start, stop, and reset the game (through keyboard shortcuts).
- When the game starts, the instructions for all robots are executed sequentially (for all robots at the same time), and the robots interact with the atoms and merged molecules.

> **Note**  
> The terms *atom* and *molecule* are incorrect from the perspective of modern chemistry and anachronisms from the perspective of classical alchemy. Nevertheless, we use them as a simple metaphor that matches the prototyped game mechanics.

We made the following simplifications of the original game mechanics:

- Instead of a hex map, we use a simple square map for the desk (four directions per arm).
- We do not actually force atoms and robot arms to the grid of the map.
- Reduced set of robot arms and instructions (currently only rotating arms).
- Limited direct manipulation of arms (currently no manual rotation).
- Relaxed distinction between editing and execution modes (no placeholders for atoms).
- No animated execution of instructions.

In addition, we implemented the program counter (instruction pointer) as a first-class visible node (see below).

## Implementation Summary

- **Interpreting instructions:** We represent each robot as a node with an arm and a program. The program is a `Container` of instructions. Each instruction is an `OptionButton` where the user can choose an instruction type or a noop. Each instruction has an `Area2D` with a `Collide` behavior. When an instruction is collided with the moving program counter, it signals the robot arm to perform a specific action.
- **Robot arms:** Nodes with a hand, a base, and a `VisualLine` that are transformed together.
- **Drag and drop:** We represent the mouse cursor through an invisible `Area2D` that is synced with the mouse cursor through a `Controls` behavior. Through `mouse_down` and `mouse_up`, we maintain a `dragged_node` in `G` that is moved together with the cursor node.
- **Grab and release:** Reparent the grabbed atom or molecule from the desk to the relevant arm or back.
- **Merging:** Collision triggers a code expression that searches for `overlapping_areas`, finds the first two molecules from them (if any), and reparents the contents of one of them into the other one. Each atom is initially contained in a single molecule, and each molecule has the group `molecules`. Molecules that are currently being dragged or grabbed are preferred for staying.
- **Program counter:** Moved through a conditional `Clock` that is paused and resumed through `Key`s. Reset through a code expression from another `Key`. On reset, each arm is reset to its original rotation (preserved in a `Marker2D` child).

## Insights

- A satisfying element of the game is the increasing effectiveness of systems. We can currently simulate this by placing many atoms at the starting point of the arms and gradually increasing the speed through the value slider.
- Direct manipulation is crucial for the puzzling experience (in our prototype, we cannot rotate arms manually).
- The relaxed distinction between editing and execution modes is inconvenient because the execution does not always start in the same state but on the other hand allows us to exploit the instructions for customizing the initial setup of robot arms.
- The visible program counter, which can also be scrubbed, to us provides a better means for visualizing and manipulating the execution than the stepping buttons in the original game. To make it even better, we could detect the scrubbing direction and play the inverse operation of each instruction when scrubbing right-to-left for a true back-in-time debugging experience.
- The connection between an arm and its related program lane is hard to discover. Highlight-on-hover helps.
- The execution of instructions is sometimes hard to discover by looking at the desk. Animated rotation etc. could help.

## Considerations for the Framework

### New Behaviors or Functionalities

- better support for **drag and drop:** an out-of-the-box `MouseCursor` node? how to restrict nodes for dragging and dropping? other approaches?
- better support for **state management:** create snapshots of certain state of certain nodes and restore them later? how would this relate to a StateMachine behavior? can we load back snapshots from the running game into the local scene?
- add support for **non-pronto nodes as connection sources,** e.g., for using signals from the Godot UI
- **a Loop behavior:** Run a code/trigger a connection `n` times?
- **a Once/Init behavior:** We frequently abuse a `Clock` and set it to `one_shot=true`, `duration_seconds=0`. This could be made a first-class behavior.
- **a VariantSpawner:** Spawn one of many child nodes, selected by an argument to the `spawn()` method?

### Behavior Convenience

- Add descriptions to properties (especially for `Spawner`, there are already comments but they are not displayed in the inspector)
- Connections do not work after reparenting nodes (relative paths do no longer match?)
- **Clock:** add a `stop()`/`pause()` method
- **Collision:** support `StaticBody`
- **Move:** moving nodes do not trigger collisions (?)
- **Placeholder:**
  - control collision layers
  - control shape: choose between rectangle, circle, triangle, ...?
  - add a `flash()` method to improve hovering and debugging scenarios
  - collision does not support reparenting (collision shape is not updated after reparenting?)
- **Spawner:**
  - nested spawners have no blueprint to spawn (first child is already removed while still inside outer spawner)
  - cannot layout spawned nodes inside `Container` (due to intermediate `path_corrector` node)
- **VisualLine:**
  - bug: not rendered in editor mode
  - uses wrong coordinate system after rotating or spawning (?) parent node

### Editing

- bug: after copying behaviors in scene tree, icons appear as a visible child of the copied node
- **Connections:**
  - [x] bug: connections do not stop to highlight (fixed via 24ab6f1ca1ed44c3d77a43e7a3ce38d589545bd4)
  - truncation of lines sometimes too harsh (depend on line length?)
- **Scripts:**
  - feat: full text search over all scripts?
  - feat: jump from a pronto script to the composing connection? (e.g., landed in the script from a breakpoint, error, or a message in the debugger console)
- **Windows:**
  - bug: cannot open multiple windows for different connections that have the same behavior, goal, and trigger
  - bug: opening code in editor before saving connection discards typed changes
  - feat: change window size (or even better: size of individual code panes)

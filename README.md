# Pronto

![Screenshot showing Godot with pronto elements](https://github.com/hpi-swa-lab/godot-pronto/blob/master/images/screenshot.png?raw=true)

Pronto is a framework for [Godot](http://godotengine.org) to make prototyping game mechanics faster. It is *not* a framework aimed at helping to create entire games faster. The resulting prototypes are a means to quickly explore ideas, throw away the prototype, and only properly implement ideas that turned out well.

## Function

The main idea of Pronto is to make behavior visible. Our hypothesis is that it will be easier to create and tweak game mechanics. For example, instead of defining numbers in code for the distance a platform moves, we use handles in the game world to visually direct it.

Pronto consists of a set of Godot Nodes called `Behavior` that can be added to a Godot scene. These behaviors are aspects that, when combined, result in the expression of complex behavior in the Godot scene. All behaviors have visual representation in the scene and primarily function through an event system called Connections. For example, if a timer reaches 5 seconds, a new enemy spawns.

## Phase 1: Creating a Prototype

Build a tiny Godot game but focus on a single mechanic. Do not focus on visuals. Polish only where it is essential for the mechanic you are creating. Where possible, use the below advice and helpers instead of code for implementation.

When choosing a mechanic, ask yourself first: Would it be better/faster to build a paper prototype? (If so, consider another mechanic.) What is the minimal feature set I need to implement to see if the mechanic is good? Try and pick a mechanic that is not necessarily the core of the genre but adds an interesting aspect to it and only implement that.

To get started, create a branch with the following pattern:
```
week-[week number]-[mechanic name]

(e.g., week-0-kart-dash for the tutorial session)
```

### Behaviors

The following list of behaviors act primarily as triggers of events.

| Behavior | Function                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| -------- |---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| AlwaysBehavior | Triggers every frame. Analog to Godot's `_process` function. Can be paused.                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| ClockBehavior | Triggers after or for a set time. Can be set to paused and to only trigger once. When looking to trigger for a specific duration the `Trigger Every Frame` property of `Unil Elapsed` needs to be enabled. This will trigger every frame until the timer is elapsed. If you wish to trigger e.g. every second (instead of every frame) you can activate `Trigger Every X Seconds` and set the `Trigger Interval In Seconds` to `1`. Hint: Intervall should not be smaller than typical time between frames (delta). |
| CollisionBehavior | Triggers when something collides with its parent. The `collided` signal also provides the `direction` of the collision pointing in the direction from the parent to the node it collided with. NOTE: only works for Area2D, RigidBody2D and CharacterBody2D as of now.                                                                                                                                                                                                                                              |
| ControlsBehavior | Triggers for mouse interactions and offers a convenient set of triggers for keyboard movement. Exact keybindings are chosen via the `Player` property which allows for up to 3 different controls (Player 1: `Arrowkeys`, Player 2: `WASD`, Player 3: `IJKL`).                                                                                                                                                                                                                                                      |
| DragBehavior | Allows users to drag and drop the parent node using the mouse. Offers signals for hovering/unhovering, dragging/dropping, and moving the node. Supports different types of nodes, including character bodies, rigid bodies, static bodies, sprites, placeholders, and controls. |
| KeyBehavior | Triggers when a single keyboard key is pressed or released.                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| NodeReadyBehavior | Triggers once after the node (and all its siblings) are [ready](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-ready).                                                                                                                                                                                                                                                                                                                                                            |
| SignalBehavior	| Forwards a signal when triggered, including arguments.	|

The following list of behaviors primarily cause effects when triggered.

| Behavior | Function |
| -------- | -------- |
| BindBehavior | Optionally reads some properties and then writes one property of its parent. Changes to the properties it reads are synced every frame. The read properties are accessible in the convert expression; the first under `value0`, the second under `value1` and so on. For example, create a Label node, add a Bind node as a child, use `text` as property and put any expression in its `convert` field. Another example would use a Clock with a Bind node as a child that uses `duration_seconds` as a property to change the trigger-time depending on a Value-Behavior. |
| CodeBehavior | It holds an `execute()` function with both user-definable arguments and a function body, which allows for arbitrary code execution. After `execute()` is called an `after` signal is emitted that carries the execution result, which can be used for chaining. |
| MoveBehavior | When triggered, moves its parent. Can be set to move along global or local axes. Supports handling of gravity. |
| PlatformerControllerBehavior | Makes the parent behave like a platformer character, meaning that it can jump, move horizontally, and is affected by gravity. Must be a child of a [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html). |
| QueryBehavior	| Searches for nodes in the scene and emits signals for results. Properties allow to filter, sort, and limit results. Can be used for tasks such as destroying all enemies in a certain radius, infecting a random player, or finding the nearest health pack.	|
| SceneRootBehavior | Provides access to the `SceneTree` from Godot. It offers the signals `node_added(node: Node)`, `node_remove(node: Node)` and `tree_changed()` from the `SceneTree`. Additionally, it implements three methods for executing lambda functions on all or a specific subset of nodes in a given `group`. |
| SignalBehavior	| Forwards signals when triggered, optionally with arguments. Useful for abstraction/encapsulation of lower-level signals, signal renaming, or logical OR-gating of signals.	|
| SpawnerBehavior | When triggered, spawns whatever its child nodes are at its current location in the scene. Single children nodes can be spawned by modifying the optional index argument in each spawning method to just the respective child node. Use -1 as index to spawn all children. Set use_spawn_shape to true to randomly spawn children in the given shape or polygon. When using a Polygon2D dont use it as a child of the spawner. |
| StopwatchBehavior | Starts counting up time when triggered. Can be reset. |

The following list of behaviors manage state or communicate visual properties.

| Behavior | Function |
| -------- | -------- |
| BackgroundBehavior | Add to your scene to change the background color of the scene. |
| CameraShakeBehavior | Add as a child of a camera and call its `add_trauma` function to add shake. |
| GroupBehavior | Draws a shape around its children to group them visually. Only visible in the editor. |
| HealthBarBehavior | Show a rectangular health bar. Offers methods to manipulate the current health and emits a signal when health drops to zero. |
| InspectBehavior | Add as a child of a node to inspect its properties inside the game. |
| InstanceBehavior | Allows you to define a template subtree of Nodes that you want to repeat multiple times without copy-pasting. Add your template as a child of the Instance node, then hover the connection dialog and click the "Instance" button. Note: internally, this creates a "hidden" scene that you need to commit as well. You can thus use **"Editable children"** in Godot by right-clicking the instance and tweaking properties while inherting the rest. |
| PlaceholderBehavior | Show a colored rectangle with a label. Useful as a quick means to communicate a game object's function. Functions as a collision shape, so you don't need to add another. Instead of a rectangle a placeholder can also display a sprite instead (use the Sprite Library in the Inspector to choose an existing texture or load your own). Can be `flash()`ed in a different color. |
| StoreBehavior | Use the Godot meta properties to store state. You can configure it to store values in the global dictionary `G` and access it via `G.at(prop)`. |
| ValueBehavior | Show a constant you can use in expression visually as a slider. Note that these are shared globally, so create new names if you need to use different values. |
| VisualLineBehavior | Show a colored Line between two Nodes. Useful as a quick visual connection. |

### Hints

* Expose the crucial variation points of your mechanic via the Value behavior. You can drop any property of a Node onto the scene to create a Value automatically.
* Focus on quick-and-dirty, especially when adding code. The second week is used to consolidate changes in the framework.
* Don't be afraid of copy-and-paste. Copy even your entire prototype, if you want to try multiple directions. If that seems tedious in your use case, consider the `Instance` behavior.
* Try to cram everything for your prototype in a single Godot scene so that changing any aspect is possible without having to switch scenes. Make use of the Spawner and Instance Behaviors to facilitate this.

* You can use the `set` function to modify any properties when a connection triggers.

### Juice
The following list of nodes dont add new functionality, their purpose is to add a bit of juice to your prototypes. They may not make your prototypes good, but they can add to them.

| Juice | Function |
| -------- | -------- |
| SparkleJuice | Make your scene sparkle! |

### Connections

Connections are an extension of Godot signals to be more flexible. Connections can be dragged from any behavior to any arbitrary node in a scene. They are the primary means to assemble your game by wiring Behaviors together.

* Creating
	* Connections are created by hovering the "+" that appears below selected nodes. There are two types of connections.
	* The type "target" is created by dragging a signal from the list onto its receiver. From the list in the dialog, you can either choose any method to invoke or choose `<statement(s)>` to execute arbitrary code. In the expressions for the arguments or the arbitrary code, you can write Godot expression that can access `from` and `to`.
	* The type "expression" allows to execute arbitrary Godot code without a receiver node. Create an `expression` connection by double-clicking a signal in the list. You can access `from` in the code.
* Editing
	* You can define a condition for the connection to trigger by entering a Godot expression in condition field. You may refer to `from` and `to` in the expression.
	* You can use the <kbd>+</kbd> icon in the header of the connection editor to add references to further nodes by specifying a node path relative to the `from` node. You can use these nodes in any statement, argument, or condition expression using `ref0`, `ref1`, etc. You can right-click these variables in the connection header to edit their path or remove them.
	* You can disable a connection by unticking the checkbox in the top-right or in its context menu.
	* You can also pin a connection editor so that it remains in the scene after saving them. You can click and drag editors in the scene as well. You can drag the handles at the bottom right of each text field to resize the editor.
	* You can press the "open script" button next to any code expression to edit it in a full-screen Godot tab which provides you better syntax highlighting and autocompletion.
* Reordering
	* From the context menu of a connection, choose "Move to top".
* Deleting
	* Open the connection, then click on the trash icon in the top-right.
	* Alternatively, right-click the connection and choose "Delete".

### Expressions

Pronto scatters code throughout the scene to be as close to the place where it is relevant. Since there is limited space on the screen, we provide a set of utility functions that make formulating common expressions easier. Some are documented below, you can find all in `U.gd`. (Feel free to extend these.)

| Name | Function | Example |
| -------- | -------- | ------- |
| `u(node: Node)` | Wrap the given Node to expose the utility functions for it. | `u(other).at("score")` |
| `closest_that(cond: Callable)` | Find the closest node that matches the given criterium. First checks children, then children of parents in a breadth-first search. | `closest_that(func (n): return n is Node)` |
| `group(name: String)` `group_do(name: String, c: Callable)` | Get all nodes in the given group. | `group_do("enemy", func (e): e.queue_free())` |
| `at(name: String)` | Find the "closest" `State` that has a field called `name`. If none is found, checks global state in `G`. | `at("score")` |
| `put(name: String, val: Variant)` | Find the "closest" `State` that has a field called `name` and store the given value. If none is found, checks global state in `G`. | `put("score", 0)` |

### Common Pitfalls
* PhysicsBody2D
	* Collisions only work when contact monitor is on and the max contacts is at least 1.
	* PhysicsBody2D does not report collisions with Area2D. Instead, listen for collisions with the PhysicsBody on the Area.
* StaticBody
	* Does not support reporting collisions at all in Godot. You can instead listen for collisions on the other collision partner.
* Connections
	* The `$` shorthand of GDScript does not work. Use get_node() instead.
	* `self` is sadly not defined in connections. Use `from` and `to` instead, or make use of any of `U`'s helpers (which are relative to `from`).
	* Moving nodes around will break connections.
* Instance
	* Be careful if you used the "Editable Children" option to modify nodes in an instanced subtree and then move the corresponding nodes in the template. Your modifications will be lost.

### Video Changelog

* 30-90 seconds (no need to cut the video, can be shaky and raw)
* show what you did and what insights you gained
* you are encouraged to open the game with a couple different parameter configurations and show the impact

## Phase 2: Extending the Framework

### Writing a New Behavior

1. Choose an icon to use as thumbnail from [the Godot source](https://github.com/godotengine/godot/tree/master/editor/icons) (it is recommended to download the source as ZIP for easily browsing the list).
2. Create a {Name}.gd file in `addons/pronto/behaviors`.
3. As a header for the file, use:
```python
@tool
#thumb("IconName")
extends Behavior
```
4. Proceed to write a Godot Node class as regular, e.g. by using @export and signals.

> ⚠️ make sure to call super implementations of all overriden methods, e.g. `super._ready()` and `super._process()`.

### When do I have to reload what?

* Re-enable the plugin (go to Project>Settings>Plugins and toggle Pronto off and on)
	* When creating a completely new `Behavior` file.
* Re-open the scene to update existing Behaviors
	* When changing a `_ready` function.
	* When creating a new `_process` function.
* Switch scenes back and forth
	* When updating a `_draw` function if no one calls `queue_redraw`.
* If everything goes wrong :-)
	* Reload the project from the main menu > Project > Reload Current Project
	* TODO: reproduce in which cases this is necessary

#### Helpers

As helpers for writing commonly needed functionality, you can use the below:

##### Configuration

* `connect_ui -> Control` show the returned Control at the top of the connect popup (that is opened via the "+").
* `show_icon() -> bool` return false to not show the configured icon for the behavior on the canvas.

##### Handles

You can return a list of handles (knobs on the canvas that you can move). See `Placeholder` and `Value` behaviors for examples.

Handles can exist in local space of the nodes in the canvas or in the space of the overlay (independent of the canvas' zoom).

##### Lines and Text Below a Behavior

You can draw lines between nodes or put text underneath your behavior by returning Line instances from the `lines()` function.

##### Canvas Override and Events

If you need to add more controls to your behavior, you have to use the canvas override hooks. You can see the implementation of handles in `Behavior.gd` as an example of this.

Override `_forward_canvas_draw_over_viewport(viewport_control: Control)` to draw in the overlay space (independent of the canvas' zoom).

Override `func _forward_canvas_gui_input(event: InputEvent, undo_redo: EditorUndoRedoManager)` to react to events that occur on the canvas. Return `true` if you want to absorb the passed element.

> ⚠️ make sure to call the super implementations if you override either of these, or handles will no longer work.

##### Runtime Values

In `ConnectionDebug.gd` you can communicate values from the game back to the engine.

##### Building UI

* `EditorIcon`: a texture that will load any of the built-in icons and color it according to the configured theme.
* In `ExpressionInspector.gd` you can specify that a property should get a GDScript code editor.

### Hints on Designing new Behaviors

* Don't bundle too much: give each concern its own behavior, e.g. appearance, movement, shooting. Design behaviors such that they are easy to connect to one another instead of pre-packaging them with lots of concerns.

## Phase 3: Deploying your Prototype/Game

To deploy your game to [hpi-swa-lab.github.io/godot-pronto/](https://hpi-swa-lab.github.io/godot-pronto/) you can use the [Build & Deploy Game](https://github.com/hpi-swa-lab/godot-pronto/actions/workflows/build-deploy.yml) Action.

### Preparation

Before you can deploy your game check the following:

1. Make your game the main scene of the godot project.
2. Make sure that all assets you use are inside your projects folder (e.g. `prototypes/myPrototype`).
3. Make sure that no filenames or folders have a `space` character in them.

#### ExportBehavior

To automatically export your game you have to add an `ExportBehavior` (do not rename this node!) anywhere in your game. There you can configure settings such as `title`, `description` and `authors` of the game, as well as how the `thumbnail.png` gets generated.

If you then commit your game it will automatically trigger the workflow and deploy your game. If everything went well it should push your game to the `gh-pages` branch. This automatically triggers another workflow to rebuild the page. Wait until this workflow has completed before going to the next step.

### Testing

After the workflow executed you can head over to [hpi-swa-lab.github.io/godot-pronto/](https://hpi-swa-lab.github.io/godot-pronto/). You should see your game appear in the list of games. Click on the "Play Now" button and check if everything is working.

### Deploying Changes

If you have made any changes to your game and want to deploy a new version, you can just repeat this process. Any existing version of your game will be overwritten.

### Troubleshooting

If you accidently trigger the workflow with an incorrect folder name it may execute without generating any errors but will create a new game in the [gh-pages branch](https://github.com/hpi-swa-lab/godot-pronto/tree/gh-pages). This will automatically be rendered into the list of games. In order to delete it, you have to manually remove it from the gh-pages branch. Please be carefull when doing so and do not delete any other files other than the projects folder you want to delete.

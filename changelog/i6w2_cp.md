# Changelog

## i6w2_cp

## New Features

- **New `Signal` behavior:** Can be triggered through `trigger()`, `trigger1(arg0)`, ... and emits the `triggered(arg0, arg1, ...)` signal in turn.

  While technically trivial, this behavior has several use cases:
  
  1. **Abstraction/Encapsulation:** Forward signals from a very specific group of nodes to the rest of the scene, acting as a facade.
  2. **Renaming:** Give an explaining, domain-specific name (e.g., `GameOver`) to a signal that was originally emitted by a technical behavior (e.g., `collided`).
  3. **Logical OR gate:** Combine multiple signals into one, e.g., to trigger an action when any of the signals is emitted.

  The signal can be disabled through the `enabled` property.

- **New `Query` behavior:** Searches for nodes in the scene and emits signals for results. Can be used for tasks such as destroying all enemies in a certain radius, infecting a random player, or finding the nearest health pack.

  The behavior provides several properties for filtering, sorting, and limiting results:
  
  - **Filtering:** Only find nodes ...
    - within a path (`only_below`),
    - within in a group (`group`),
    - of a class (`clazz`),
    - within a distance to the query node (`radius`),
    - that match a custom predicate script (`predicate`).
  
    All filters can be combined and are evaluated with logical AND.

  - **Sorting:** Sort results by ... (`priority_strategy`, ascending)
    - their distance to the query node, or
    - a custom priority script (`priority_script`).
  
  - **Limiting:** Only return a certain number of results (`max_results`). Select results from the full list (`selection_strategy`) ...
	- based on their priority, or
	- randomly, and weight the results (`random_weight_strategy`) ...
	  - uniformly,
	  - by their inverse distance to the query node, or
	  - by a custom script (`random_weight_script`).
  
  Emitted signals:
  
  - `found(node, token, priority, selection_arg)`: Emitted for each result. `token` is an optional identifier for the query. `priority` and `selection_arg` correspond to the sorting and limiting properties, if set.
  - `found_all(nodes, tokens, priorities, selection_args)`: Emitted for all results (even if none) at all. `nodes`, `tokens`, `priorities`, and `selection_args` are arrays of the corresponding values.
  - `found_none(token)`: Emitted if no results were found.
  
  Trigger the query through `query([token, [parameters]])`. Through `parameters`, any property of the query can be overridden dynamically. For example, you can change the search radius based on the player's current health.
  
  ### Known Limitations
  
  - Cannot filter for custom Pronto classes (i.e., behaviors) because they are not registered in the ClassDB. See also `Utils.get_specific_class_name()` for a similar issue.
  
  ### Future Work
  
  - **Query shapes:** Allow to specify a custom shape for the query, e.g., a rectangle or a polygon. Users could either add shapeful child nodes to a query behavior or specify shapes through its handles or its inspector. At the same time, the query behavior should also honor the exact shape of the found nodes.

    We already sketched the framework for this but did not implement it yet because we identified some technical depth related to behavior-managed shapes. At the moment, placeholders and spawners already support custom shapes and we didn't want to duplicate their logic for maintaing these shapes and configuring through the inspector or editor handles a third time. Maybe we can extract this before, e.g., to `Behavior`, a new `HandleProvider`, or a new `ShapeInspectorPlugin`? Furthermore, configuring generic shapes in the spawner seemed currently broken for us (changes to their geometry are not accepted and the console keeps spitting out DNUs).

## Bugfixes

- `DragBehavior` no longer emits drop signal before actually dropping and unfreezing parent ([#125](https://github.com/hpi-swa-lab/godot-pronto/issues/125)).
- Some bugfixes for **nested spawners:** 
  - They no longer trigger an error when duplicated by the outer spawner. (https://github.com/hpi-swa-lab/godot-pronto/pull/142/files#diff-ea7eb23cf70ccf23fd4a10ddaf859c7444cccd70e306785d61c2a2c58afe1c0bR26-R28)
  - They work again when setting a `scene_path` on the inner spawner.
  - However, the underlying issue [#143](https://github.com/hpi-swa-lab/godot-pronto/issues/143) remains unsolved.
- `Utils.global_rect_of()` (and thus `DragBehavior` et al.) no longer fails on non-2D `Node`s (as used by the spawner's internal `path_corrector`).

## Miscellaneous

- Slightly revised the arrangement of properties in the inspector of the `InspectBehavior`.
- Placeholders now reuse translucency of color for their labels as well, if any.
- Added an icon for the `StateBehavior`.

## API Changes

- *There should be no breaking changes.*
- New `Behavior.selected()` is called when the user selects the behavior in the editor. Behavior can check the current selection using `Behavior.is_being_edited()`.
- Behaviors can request an `ExpressionEditor` for a property (to edit a script in the inspector) by overriding `Behavior.wants_expression_inspector()` instead of hard-coding them. They can also provide a custom default script through `Behavior.initialize_connection_script()`.

## Documentation

- Wrote an example "pronto patterns" as a proposal for a better documentation format of behaviors ([#141](https://github.com/hpi-swa-lab/godot-pronto/issues/141)).

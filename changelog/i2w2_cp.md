# Changelog

## i2w2_cp

### New Features

- **New Inspect Behavior:** Inspect the state of any Godot node from the running game ([#23](https://github.com/hpi-swa-lab/godot-pronto/pull/23))
  - To inspect the state of a node, you can now select it in the scene tree and add an `Inspect` behavior to its children (<kbd>Ctrl</kbd> + <kbd>A</kbd>, <kbd>insp</kbd>, <kbd>Enter</kbd>). The resulting node will render the selected portion of the parent node's state in the scene. All properties are lively updated.
  - **Properties:** In the inspect behavior's inspector, you can select any properties from the node's class and its superclasses.
  - **Multiple properties:** You can also select multiple properties to inspect at once. Choose <kbd>\<remove></kbd> from the top of the dropdown to remove a property from the list again.
  - **Custom expressions:** You can also select <kbd>\<statement(s)></kbd> at the top to enter a custom code expression that is evaluated with access to the `target` node.
  - **Highlighted changes:** When the inspected properties change, the behavior will highlight the changed properties for a short time.
  - **Dynamic layout:** You can use the resize handles to change the size of the inspect behavior. The initial layout avoids overlapping with the parent node's and its children's visible shapes. You can also make the behavior *sticky* to avoid it being moved or rotated with the parent node.
  - **Tooltips and truncation for long strings:** Value strings that are too long to fit into the selected layout are truncated. Hover over the truncated string to see the full value in a tooltip.
  - **Customizable appearance:** You can change the text and background colors of the behavior in the inspector.
  - **Known issues:**
    - Editing an expression while the game is open is tricky as the expression is evaluated as-you-type. This can lead to unhandlable runtime errors. To avoid this, prefix the expression with `#` until you are done editing it.
    - Custom expressions can only be displayed when the game is open.

- **Improved error handling for `eval`** ([6a754c2](https://github.com/hpi-swa-lab/godot-pronto/commit/6a754c2)): When a code expression anywhere in the system (e.g., in a connection or in an inspect behavior) contains a syntax error or cannot be saved, this error is now communicated clearer to the user in the output console. (You will no longer see the cryptic error message "invalid set index 'ref'".)

| `Inspect` behavior in scene | Properties of `Inspect` behavior |
| --- | --- |
| ![](./i2w2_cp_inspect_scene.png) | ![](./i2w2_cp_inspect_properties.png) |

### Bug Fixes

- Fix console errors when interacting with a Godot scene in the editor while or after inspecting objects from a debugger session ([#22](https://github.com/hpi-swa-lab/godot-pronto/pull/22))
  - You should no longer see the following error messages:
    - >     res://addons/pronto/pronto.gd:80 - Invalid call. Nonexistent function '_forward_canvas_gui_input' in base 'EditorDebuggerRemoteObject ()'.
      >     res://addons/pronto/pronto.gd:88 - Invalid call. Nonexistent function '_forward_canvas_draw_over_viewport' in base 'EditorDebuggerRemoteObject ()'.
    
    - >     Left operand of 'is' is a previously freed instance.

### API Changes

- Code evaluation/`ConnectionList`: Added `ConnectionList::eval_or_error() -> ExecResult` for handling syntax errors in code expressions gracefully. `ExecResult` offers an `error` property and a `value` property for accessing the result of the evaluation.

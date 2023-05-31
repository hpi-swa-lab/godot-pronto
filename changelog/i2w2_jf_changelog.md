# Changelog

## Display Correct Argument Names in Connection Window

We now display the correct parameter names instead of `arg0`, `arg1`. This also works for the newly created `Code` Behavior where the user can set arbitrary parameters in the `Inspector`.

## Code Behavior

Added a new Behavior called `Code` to provide a container for code execution. It can have parameters that are added in the `Arguments` property (provide names to use in the code). In the connections, those parameters can be set for the call that is triggered with the `execute()` function of the Code-Node.

The Code-Node also has a signal `after(result)` which triggers after the code execution and provides the return value of the code statement as `result` to be used later on.

This enables chaining of different nodes and can be used to reduce code redundancy.

You can also add a `Label` to the Node to keep track of multiple Code Behaviors and their functionality.

## ExpressionInspector

We improved the displayment of the expression elements that are used in the inspector (currently available in the `Bind`, `Code` and `Watch` Behavior). They now take all the available width of the inspector to display the code. Before, this expression window was sized differently based on its content which lead to a lot of resizing when editing.

## Replace Icon for the "Open file for placing breakpoints" button

We update the icon that is used for opening the automatically created godot script files for every expression. Previously, the icon was a red dot. Now we update it to the "DebugStep" Icon since it seems to be a better fit in our opinion.

## BottomText centered

We fixed the placement of `BottomText` (used for example in `Key`- and `Code`-Nodes) to now be centered below the node (before this was shifted to the right).

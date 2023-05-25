# Changelog

## Display Correct Argument Names in Connection Window

We now display the correct parameter names instead of `arg0`, `arg1`.

## Code Behavior

Added a new Behavior called `Code` to provide a container for code execution. It can have parameters that are added in the `Arguments` property (provide names to use in the code). In the connections, those parameters can be set for the call that is triggered with the `execute()` function of the Code-Node.

The Code-Node also has a signal `after(result)` which triggers after the code execution and provides the return value of the code statement as `result` to be used later on.

This enables chaining of different nodes and can be used to reduce code redundancy.

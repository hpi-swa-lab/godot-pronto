# Changelog Iteration 3 Week 2

## Pronto Connection Window (Ideas for improvement)

* Every time you write a character in one of the Expression Inputs it gives an error message `Condition "p_ptr == nullprt" is true.` in the console (except when it is a valid expression). This couuld be changed to only produce this error after editing of the input field is complete and the user moves the focus away from this field.

* Additionally one could check if the returned type of the expressions match the expected type of the parameter of that function.

## Decisions we made regarding the SceneRoot Behavior

We had a long discussion about what functionality the SceneRoot should provide. We knew that we wanted to give an easy way to call a certain function for each element of a certain group so this is the first thing we did. However, this was not as straight forward as one might think. That is why we decided to provide even better functionality than the `call_group(group: StringName, method: StringName, ...) vararg` function the SceneTree provides. 

We decided to use a lambda function as a parameter instead that is also given the node it is executed on. This allows for manipulation of these nodes different from just calling their own functions with certain parameters.

The new function now is called `apply(group: StringName, lamda_func: Callable)` and takes the group name as well as a lamda function of format `func(node): ...`. To make it easy for users to understand how the lamda function must be defined, `func(node): null` is automatically set in the connection window by default, explaining the usage of the lamda funtion.

Our SceneRoot Behavior also exposes some of the signals of the SceneTree:
  - `node_added(node: Node)`
  - `node_remove(node: Node)`
  - `tree_changed()`
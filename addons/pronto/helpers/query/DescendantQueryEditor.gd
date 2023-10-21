@tool
extends VBoxContainer

signal changed_query

var query: DescendantQuery
var query_behavior: QueryBehavior

func set_query(q: DescendantQuery):
	query = q


func set_query_behavior(q: QueryBehavior):
	query_behavior = q


func _change(path):
	query.path = path
	changed_query.emit()


func _ready():
	%ChangePathButton.text = query_behavior.get_node(query.path).name
	%PathLabel.text = "(at \"%s\")" % query.path


func _add_node_to_tree(node: Node, parent_item: TreeItem = null):
	var item: TreeItem
	if parent_item == null:
		item = %NodeTree.create_item()
	else:
		item = parent_item.create_child()
	
	item.set_text(0, node.name)
	item.set_metadata(0, node)
	
	for child in node.get_children():
		_add_node_to_tree(child, item)


func _on_change_path_button_pressed():
	%NodeTree.clear()
	_add_node_to_tree(get_tree().get_edited_scene_root())
	%NodeSelectionDialog.show()


func _on_node_selection_dialog_confirmed():
	var chosen_node = %NodeTree.get_next_selected(null).get_metadata(0)
	query.path = query_behavior.get_path_to(chosen_node)
	changed_query.emit()


func _on_node_tree_item_activated():
	%NodeSelectionDialog.hide()
	_on_node_selection_dialog_confirmed()

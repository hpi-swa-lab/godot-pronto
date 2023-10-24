@tool
extends PanelContainer

var DropNode = preload("res://addons/pronto/signal_connecting/drop_node.tscn")

var undo_redo: EditorUndoRedoManager

var nodes: Array:
	set(value):
		nodes = value
		for child in nodes:
			add(child)
			for c in all_children_without_position(child):
				add(c)

func _ready():
	 # FIXME godot 4.2 beta did not assign a background color to the panel
	var s = G.at("_pronto_editor_plugin").get_editor_interface().get_editor_settings()
	var box = StyleBoxFlat.new()
	box.bg_color = s.get("interface/theme/base_color")
	add_theme_stylebox_override("panel", box)

func add(node: Node):
	var row = DropNode.instantiate()
	row.undo_redo = undo_redo
	row.node = node
	%list.add_child(row)

func all_children_without_position(root: Node, list: Array[Node] = []):
	for c in root.get_children():
		if not Utils.has_position(c):
			list.append(c)
			all_children_without_position(c, list)
	return list
